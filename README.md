# aisse-collection
Collection of harness-components for AI-Supported Software Engineering (AISSE).

This repository contains a collection of harness-components that can be used to support AI-Supported Software Engineering (AISSE) tasks. The components are designed to facilitate the integration of AI techniques into software engineering processes, enabling developers to leverage AI capabilities for improved software development and maintenance.

The repository is currently under development and will be updated with new components and features over time. 

Contributions from the community are welcome to enhance the collection and expand its capabilities.

# How to copy skills to your project

If you have many AI agent supported projects, you need some centralized place to store and manage your skills. This repository is designed for that purpose. You can copy the skills from this repository to your project using the following command:

```bash
scripts/symlink-skills.sh --target-project <absolute-path-to-your-project>
```

This script first ask you about skills, that you want to have in your project. Then it creates symbolic links to the selected skills in your project. 

Below is an example of how to use the script:

```bash

% scripts/symlink-skills.sh --target-project /Users/vsirotin/VSCodeProjects/app-server     

[INFO] Available skills in /Users/vsirotin/VSCodeProjects/aisse-collection/.github/skills:

  1) angular
  2) bug-fixing
  3) common-development
  4) feature-development
  5) post-task
  6) testing
  7) typescript

Enter skill numbers to link (space-separated, e.g. '1 3 5' or 'all'): 1 2 3 4 5 7  

[INFO] Selected skills:
  - angular
  - bug-fixing
  - common-development
  - feature-development
  - post-task
  - typescript

Create symlinks for these skills? [Y/n] Y
[OK] Created symlink: angular -> /Users/vsirotin/VSCodeProjects/app-server/.github/skills/angular
[OK] Created symlink: bug-fixing -> /Users/vsirotin/VSCodeProjects/app-server/.github/skills/bug-fixing
[OK] Created symlink: common-development -> /Users/vsirotin/VSCodeProjects/app-server/.github/skills/common-development
[OK] Created symlink: feature-development -> /Users/vsirotin/VSCodeProjects/app-server/.github/skills/feature-development
[OK] Created symlink: post-task -> /Users/vsirotin/VSCodeProjects/app-server/.github/skills/post-task
[WARN] Skipping 'typescript': target already exists at /Users/vsirotin/VSCodeProjects/app-server/.github/skills/typescript

========================================
[INFO] Operation complete.
========================================

  Source skills directory : /Users/vsirotin/VSCodeProjects/aisse-collection/.github/skills
  Target project          : /Users/vsirotin/VSCodeProjects/app-server
  Target skills directory : /Users/vsirotin/VSCodeProjects/app-server/.github/skills

  Created symlinks        : 5
  Skipped (already exist) : 1

```  

You can make skills in your projects reasonly to prevent accidental changes in the original skills. 

For this you can set in your `.vscode/settings.json`:

```json
{
   "files.readonlyInclude": {
    ".github/skills/**": true,
  }
}
```