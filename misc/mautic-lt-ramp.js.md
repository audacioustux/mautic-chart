```bash
SCRIPT="mautic-lt-ramp.js" docker run --rm -v "$PWD:/lt:rw,z" -u "1000:1000" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT="/lt/$SCRIPT.html" ghcr.io/grafana/k6:latest run /lt/$SCRIPT
```