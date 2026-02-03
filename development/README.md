# Development Resources

This directory is intended for development-related Git repositories and resources that support the n8n installation suite.

## Purpose

- **Git Submodules**: Link external development repositories
- **Development Tools**: Scripts and utilities for development workflows
- **Testing Resources**: Test configurations and mock data
- **Templates**: Reusable templates for various environments

## Typical Contents

### Git Repositories (as submodules)
```bash
# Example: Add a development workflow repository
git submodule add https://github.com/example/n8n-workflows-dev.git workflows-dev
git submodule add https://github.com/example/n8n-custom-nodes.git custom-nodes
```

### Development Tools
- Custom node development environments
- Testing frameworks for workflows
- CI/CD pipeline configurations
- Development Docker compositions

### Templates
- Workflow templates for common use cases
- Environment configuration templates
- Documentation templates

## Getting Started

1. **Initialize development environment:**
   ```bash
   # From the development directory
   ../scripts/deployment/setup-development.sh my-dev-workspace development
   ```

2. **Add external repositories:**
   ```bash
   # Add workflow repositories as submodules
   git submodule add <repository-url> <local-name>
   ```

3. **Update all development repositories:**
   ```bash
   git submodule update --recursive --remote
   ```

## Development Workflow

1. **Local Development**: Use localhost environment
2. **Testing**: Deploy to staging/preproduction
3. **Production**: Deploy via Ansible to production servers

See [../scripts/deployment/setup-development.sh](../scripts/deployment/setup-development.sh) for automated development environment setup.

## Related Documentation

- [Multi-Environment Guide](../documentation/MULTI-ENVIRONMENT.md)
- [Development Setup](../documentation/README.md#development-setup)