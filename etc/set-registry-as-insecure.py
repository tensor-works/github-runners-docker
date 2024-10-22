import os
import json
import platform
from pathlib import Path

def get_daemon_path():
    """Get the appropriate daemon.json path based on OS."""
    system = platform.system().lower()
    
    if system == "linux":
        return Path("/etc/docker/daemon.json")
    elif system == "windows":
        # Try ProgramData first
        program_data_path = Path(os.environ.get('PROGRAMDATA', 'C:\\ProgramData')) / "docker" / "config" / "daemon.json"
        if program_data_path.parent.exists():
            return program_data_path
        
        # Fallback to user's home directory
        return Path.home() / ".docker" / "daemon.json"
    else:
        raise OSError(f"Unsupported operating system: {system}")

def update_daemon_config():
    """Update or create daemon.json with insecure registry configuration."""
    daemon_path = get_daemon_path()
    
    # Default configuration
    new_config = {
        "insecure-registries": ["localhost:5000"]
    }
    
    # Ensure parent directory exists
    daemon_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Read existing configuration if it exists
    if daemon_path.exists():
        existing_config = json.loads(daemon_path.read_text())
        if "insecure-registries" in existing_config:
            if "localhost:5000" not in existing_config["insecure-registries"]:
                existing_config["insecure-registries"].append("localhost:5000")
        else:
            existing_config["insecure-registries"] = ["localhost:5000"]
        new_config = existing_config
    
    # Write the configuration
    daemon_path.write_text(json.dumps(new_config, indent=4))
    print(json.dumps(new_config, indent=4))
    print(f"Configuration updated at: {daemon_path}")

if __name__ == "__main__":
    update_daemon_config()