# 🚀 GitHub Runners Docker

![GitHub Runners Docker](https://img.shields.io/badge/GitHub%20Runners-Docker-blue?style=for-the-badge&logo=docker)

A robust and flexible solution for deploying self-hosted GitHub Action runners using Docker. This project simplifies the process of setting up, managing, and scaling your GitHub Actions infrastructure.

## 🌟 Features

- 🐳 Containerized GitHub Action runners
- 🔄 Easy setup and teardown process
- 🔢 Scalable architecture supporting multiple runners
- 🔧 Configurable cache directory for improved performance
- 🖥️ Cross-platform support (Windows and Unix-like systems)
- 🛠️ Integrated build and test processes

## 🏗️ Prerequisites

- Docker
- Docker Compose
- Make
- PowerShell (for Windows)
- Bash (for Unix-like systems)

## 🚀 Quick Start

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/github-runners-docker.git
   cd github-runners-docker
   ```

2. Set up the environment:
   ```sh
   make setup
   ```

3. Build the Docker image:
   ```sh
   make build
   ```

4. Start the runners:
   ```sh
   make up
   ```

## 🛠️ Usage

- **Start runners**: `make up`
- **Stop runners**: `make down`
- **View logs**: `make logs`
- **Clean up**: `make clean`
- **Run tests**: `make test`
- **Test Buildx setup**: `make test-buildx`

## 🔧 Configuration

The project uses a `.env` file for configuration. The setup process will guide you through creating this file, including setting the `DOCKER_CACHE_DIR` for improved performance.

## 📁 Project Structure

```
github-runners-docker/
├── .devcontainer/
│   └── devcontainer.json
├── docker/
│   ├── scripts/
│   │   ├── buildx-test.sh
│   │   ├── docker-access-test.sh
│   │   └── start.sh
│   └── Dockerfile.dood
├── etc/
│   ├── enable-docker-tcp.ps1
│   ├── setup-cache-dir.ps1
│   └── setup-cache-dir.sh
├── tests/
│   ├── test_docker/
│   └── test_etc/
│       └── test-enable-docker-tcp.ps1
├── .env
├── .gitignore
├── compose.yml
├── LICENSE
├── Makefile
└── README.md
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/yourusername/github-runners-docker/issues).

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- GitHub Actions team for their excellent documentation
- Docker community for continuous support and innovations
- Allessandro Baccini for providing the base [template](https://baccini-al.medium.com/how-to-containerize-a-github-actions-self-hosted-runner-5994cc08b9fb)

---

<p align="center">
  Made with by Amadou 
</p>