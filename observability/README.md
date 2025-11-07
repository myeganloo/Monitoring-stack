# MiniO Monitoring Stack

Minimal Docker Compose stack for host/container metrics and log shipping:

- cAdvisor: container metrics for Prometheus
- Node Exporter: host metrics for Prometheus
- Promtail: tails host and container logs and pushes to a remote Loki

No host ports are published; scrape/connect over shared Docker networks.

Optional: You can publish Node Exporter and cAdvisor ports and/or generate Prometheus file_sd targets so a central Prometheus can scrape these nodes automatically. Promtail also annotates logs with host and instance labels.

## Prerequisites

- Docker Engine and Docker Compose v2
- Two external Docker bridge networks: `app_net` and `web_net`
- For Ansible deployment: Ansible 2.13+ and the collections in `ansible/requirements.yml`

## Quick start (Docker Compose)

1. Create networks if they don’t exist:

```zsh
docker network create app_net || true
docker network create web_net || true
```

1. Provide `.env` with restart policy and hostname:

```zsh
printf "RESTART_POLICY=unless-stopped\nHOSTNAME=$(hostname)\n" > .env
```

1. Launch:

```zsh
docker compose up -d
```

1. Validate:

```zsh
docker compose ps
docker logs -f promtail
```

Notes:

- Prometheus should scrape `node-exporter:9100` and `cadvisor:8080` over the shared networks.
- Promtail listens on 9080 internally and pushes to Loki as configured in `promtail/promtail.yml`.

## Ansible deployment (multi-host)

Inventory example: `ansible/inventory/inventory.yml` with all variables explicit per host under `monitoring_targets`.

Key variables (per-host):

- `monitoring_project_dir`: e.g., `/opt/services/monitoring`
- `monitoring_restart_policy`: e.g., `unless-stopped`
- `monitoring_app_network`, `monitoring_web_network`: external network names
- `monitoring_cadvisor_image`, `monitoring_node_exporter_image`, `monitoring_promtail_image`
- `monitoring_promtail_http_listen_port`: default `9080`
- `monitoring_promtail_positions_file`: e.g., `/tmp/positions.yaml`
- `monitoring_loki_push_url`: full Loki push URL (can include basic auth)
- `monitoring_promtail_system_job`: label for system logs
- `monitoring_promtail_system_paths`: list of glob paths for system logs
- `monitoring_promtail_container_label`: label name for container relabeling
- `monitoring_publish_ports` (bool): publish exporters on the host; default false
- `monitoring_node_exporter_port`, `monitoring_cadvisor_port`: host ports to publish when enabled
- `monitoring_prometheus_file_sd_dir`: optional directory to render a file_sd JSON with this host's targets
- `monitoring_prometheus_reload_url`: optional Prometheus /-/reload URL to call after changes
- `monitoring_prometheus_delegate_host`: optional delegate host where file_sd will be written (e.g., Prometheus server)
- `monitoring_git_auto_push`: enable automatic git commit/push after target changes (default: false)
- `monitoring_git_repo_path`: path to git repository on delegate/target host
- `monitoring_git_branch`: git branch to push changes to (default: main)

Run it:

```zsh
# Install required collections
ansible-galaxy collection install -r ansible/requirements.yml

# Dry-run to preview changes
ansible-playbook -i ansible/inventory/inventory.yml ansible/site.yml --check

# Apply
ansible-playbook -i ansible/inventory/inventory.yml ansible/site.yml
```

Validate after deploy:

```zsh
ansible -i ansible/inventory/inventory.yml monitoring_targets -m shell -a 'docker compose -f {{ monitoring_project_dir }}/compose.yml ps'
ansible -i ansible/inventory/inventory.yml monitoring_targets -m shell -a 'docker logs --tail 200 promtail'
```

## Customization

- To add log paths, edit `monitoring_promtail_system_paths` in inventory and ensure required host paths are mounted in `compose.yml.j2` (already includes `/var/log` and Docker logs).
- To add exporters, copy the pattern in `compose.yml.j2`: join both networks; avoid exposing host ports, prefer intra-network scraping.
- Credentials: `monitoring_loki_push_url` currently holds basic auth. Consider using Ansible Vault or Docker secrets if needed.

## Git Pipeline Integration

If you want changes to be automatically pushed to git after running Ansible so the pipeline can deploy them:

1. Enable git variables in your inventory:

```yaml
monitoring_git_auto_push: true
monitoring_git_repo_path: /opt/monitoring-stack
monitoring_git_branch: main
monitoring_prometheus_delegate_host: monitoring-server.example.com
monitoring_prometheus_file_sd_dir: /opt/monitoring-stack/observability/observability-full-stack/prometheus/file_sd/targets
```

2. Ensure the git repository exists on the delegate host and credentials are configured.

3. After running the playbook, file_sd changes will be automatically committed and pushed.

4. Your pipeline should detect the changes and redeploy the observability stack.

## Layout

- `compose.yml` – services, networks, volumes (used for local runs)
- `promtail/promtail.yml` – Promtail config (used for local runs)
- `ansible/` – playbook, role, templates, and example inventory for remote deployments
