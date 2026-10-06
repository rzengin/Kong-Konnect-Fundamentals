# ==============================================================================
# B.2 Gobierno: Separación por Control Plane
# ==============================================================================

# 1. Control Plane Principal
resource "konnect_gateway_control_plane" "mock" {
  name         = "${var.demo_prefix}_MockAPI"
  description  = "Control Plane unificado de MockAPI"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pinned_client_certs"
}


# ==============================================================================
# B.3 Gobierno: Teams y RBAC
# ==============================================================================

# 1. Equipos (Teams)
resource "konnect_team" "api_developers" {
  name        = "${var.demo_prefix}_API_Developers"
  description = "Equipo a cargo del desarrollo y mantenimiento de APIs"
}

# 2. Asignación de Roles (RBAC)

# El equipo API Developers administra el Control Plane
resource "konnect_team_role" "api_devs_role" {
  team_id          = konnect_team.api_developers.id
  entity_id        = konnect_gateway_control_plane.mock.id
  entity_region    = "us"
  role_name        = "Admin"
  entity_type_name = "Control Planes"
}

# ==============================================================================
# B.4 Base Route: Healthcheck
# ==============================================================================

# Dummy service para el healthcheck (no será ruteado debido al plugin request-termination)
resource "konnect_gateway_service" "healthcheck" {
  control_plane_id = konnect_gateway_control_plane.mock.id
  name             = "Healthcheck-Service"
  protocol         = "http"
  host             = "localhost"
  port             = 8000
  tags             = ["core"]
}

# Ruta expuesta en /healthcheck
resource "konnect_gateway_route" "healthcheck" {
  control_plane_id = konnect_gateway_control_plane.mock.id
  name             = "Healthcheck-Route"
  paths            = ["/healthcheck"]
  tags             = ["core"]
  service = {
    id = konnect_gateway_service.healthcheck.id
  }
}

# Plugin para responder con un 200 OK directamente desde Kong
resource "konnect_gateway_plugin_request_termination" "healthcheck_term" {
  control_plane_id = konnect_gateway_control_plane.mock.id
  enabled          = true
  tags             = ["core"]
  config = {
    status_code = 200
    message     = "Kong Gateway is Alive! Control Plane Sync is working."
  }
  route = {
    id = konnect_gateway_route.healthcheck.id
  }
}

# ==============================================================================
# B.5 Portal: Application Auth Strategy (Identity)
# ==============================================================================

resource "konnect_application_auth_strategy" "mock_oidc_strategy" {
  openid_connect = {
    display_name = "${var.demo_prefix}_MockAPI_Auth"
    name         = "${var.demo_prefix}_MockAPI_Auth"
    configs = {
      openid_connect = {
        issuer           = konnect_identity_auth_server.mockapi_auth_server.issuer
        auth_methods     = ["client_credentials", "bearer"]
        credential_claim = ["client_id"]
        scopes           = ["read", "write"]
      }
    }
    strategy_type = "openid_connect"
  }
}

# ==============================================================================
# B.6 Konnect Identity: Authorization Server
# ==============================================================================

resource "konnect_identity_auth_server" "mockapi_auth_server" {
  name     = "${var.demo_prefix}_AuthServer"
  audience = "${var.demo_prefix}_MockAPI"
}
