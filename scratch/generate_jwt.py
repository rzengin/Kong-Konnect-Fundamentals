import jwt
import time
payload = {
    "iss": "internal-app",
    "exp": int(time.time()) + 3600
}
token = jwt.encode(payload, "super-secret-jwt", algorithm="HS256")
print(token)
