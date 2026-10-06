import os
os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import requests
import json
import urllib3

urllib3.disable_warnings()

token = os.environ.get('KONNECT_TOKEN')
base_url = "https://us.api.konghq.com/v2/control-planes"
headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

# Fetch CPs
response = requests.get(base_url, headers=headers, verify=False)
data = response.json().get('data', [])

demo_prefix = os.environ.get('DEMO_PREFIX')
if not demo_prefix:
    print("Error: DEMO_PREFIX environment variable is not set.")
    exit(1)

cp_name = os.environ.get('KONNECT_CONTROL_PLANE_NAME')
if not cp_name:
    cp_name = f'{demo_prefix}_MockAPI'
cp = next((c for c in data if c['name'] == cp_name), None)

if not cp:
    print(f"Could not find CP with name {cp_name}")
    exit(1)

print(f"CP ID: {cp['id']}")

# Export cluster endpoints
with open('endpoints.env', 'w') as f:
    f.write(f"export TELEMETRY_ENDPOINT={cp['config']['telemetry_endpoint'].replace('https://', '')}\n")
    f.write(f"export CONTROL_PLANE_ENDPOINT={cp['config']['control_plane_endpoint'].replace('https://', '')}\n")

os.makedirs('certs/mock', exist_ok=True)

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import hashes
import datetime

def generate_and_upload_cert(cp_id, path):
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    key_pem = key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption()
    )
    
    subject = issuer = x509.Name([
        x509.NameAttribute(NameOID.COMMON_NAME, u"kong-dp"),
    ])
    cert = x509.CertificateBuilder().subject_name(
        subject
    ).issuer_name(
        issuer
    ).public_key(
        key.public_key()
    ).serial_number(
        x509.random_serial_number()
    ).not_valid_before(
        datetime.datetime.now(datetime.timezone.utc)
    ).not_valid_after(
        datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=365)
    ).sign(key, hashes.SHA256())
    
    cert_pem = cert.public_bytes(serialization.Encoding.PEM)
    
    with open(f'{path}/tls.key', 'wb') as f:
        f.write(key_pem)
    with open(f'{path}/tls.crt', 'wb') as f:
        f.write(cert_pem)
        
    cert_str = cert_pem.decode('utf-8')
    res = requests.post(f"{base_url}/{cp_id}/dp-client-certificates", headers=headers, json={"cert": cert_str}, verify=False)
    if res.status_code not in [200, 201]:
        print(f"Failed to upload cert for CP {cp_id}: {res.text}")

# Generate cert for MockAPI CP
print("Generating and uploading CP cert...")
generate_and_upload_cert(cp['id'], 'certs/mock')

print("Certificates generated successfully.")
