import os
import json
import yaml

def deep_merge(base, override):
    if not isinstance(base, dict) or not isinstance(override, dict):
        return override
    for key, value in override.items():
        if key in base and isinstance(base[key], dict) and isinstance(value, dict):
            deep_merge(base[key], value)
        else:
            base[key] = value
    return base

def main():
    raw_yaml = os.environ.get('PERMISSIONS_YAML', '')
    agent = os.environ.get('AGENT_NAME', 'cogni-ai-architect')
    try:
        permissions = yaml.safe_load(raw_yaml) or {}
    except Exception:
        permissions = {}

    if isinstance(permissions, dict) and ('default' in permissions or agent in permissions):
        base_perms = permissions.get('default', {})
        agent_perms = permissions.get(agent, {})
        if not isinstance(base_perms, dict): base_perms = {}
        if not isinstance(agent_perms, dict): agent_perms = {}
        final_perms = deep_merge(base_perms, agent_perms)
    else:
        final_perms = permissions

    output_path = os.environ.get('GITHUB_OUTPUT')
    if output_path:
        with open(output_path, 'a') as f:
            f.write(f"json={json.dumps(final_perms)}\n")
    else:
        print(json.dumps(final_perms))

if __name__ == "__main__":
    main()
