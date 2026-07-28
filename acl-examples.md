# Sanitized ACL Design Examples

## Default posture

- Deny inter-VLAN traffic by default.
- Permit DNS from client VLANs to the designated internal resolver.
- Permit management access only from trusted administration endpoints.
- Permit application-specific traffic only when a documented dependency exists.

## Example dependencies

| Source | Destination | Protocol/Port | Purpose |
|---|---|---:|---|
| IoT VLAN | Internal DNS | UDP/TCP 53 | Name resolution |
| Workstation VLAN | Server VLAN | TCP 22 | SSH administration |
| Trusted clients | Printer VLAN | Printing ports | Printing |
| Media VLAN | Automation hub | Required application ports | Device integration |
