# GitHub Actions Release Creation Pipeline

This GitHub Actions pipeline automates the process of creating releases on GitHub for a list of repositories using a PowerShell script. The pipeline is triggered manually and requires the release name as an input.

## Workflow

The workflow is defined in the **[.github/workflows/release-creation-pipeline.yml](https://github.com/Leticia-Mendes/github-actions-pipelines/blob/feature/main/readme/.github/workflows/release-creation-pipeline.yml)** file. It consists of the following steps:

1. **Checkout**: Checks out the repository's code.
2. **Execute Release Creation Script**: Runs the PowerShell script **[CreateRelease.ps1](https://github.com/Leticia-Mendes/github-actions-pipelines/blob/main/.github/actions/CreateRelease/CreateRelease1.ps1)** located in the **`.github/actions/CreateRelease`** directory. This script reads the repository names and versions from the **[release-versions.yml](https://github.com/Leticia-Mendes/github-actions-pipelines/blob/feature/main/readme/release-versions.yml)** file in the root directory.
    - The release name is passed as an input parameter to the script using the **`release_name`** environment variable.
    - The GitHub personal access token is passed to the script using the **`token`** environment variable, which is stored as a secret (**`LOCAL_TOKEN`**) in the repository's settings.
4. **List Files**: Lists the files in the repository, including the generated **`ReleaseCreation.csv`** file.
5. **Push Artifacts**: Uploads the **`ReleaseCreation.csv`** file as an artifact for further use or reference.

## **Running the Pipeline**

To create releases using the pipeline, follow these steps:

1. Open your repository on GitHub.
2. Go to the **Actions** tab.
3. Select the **Release Creation Pipeline** workflow.
4. Click the **Run workflow** button.
5. Select the **Branch**
6. Provide the **release_name** input parameter.
7. Click the **Run workflow** button to start the pipeline.

The pipeline will execute the PowerShell script for each repository defined in the **`release-versions.yml`** file. It will create releases on GitHub, generate the **`ReleaseCreation.csv`** file, and upload it as an artifact.

## The CreateRelease.ps1 Script

The **[CreateRelease.ps1](https://github.com/Leticia-Mendes/github-actions-pipelines/blob/main/.github/actions/CreateRelease/CreateRelease1.ps1)** script will perform the following actions:

1. Install the **`powershell-yaml`** module if it is not already installed.
2. Create a CSV file (**`ReleaseCreation.csv`**) to store release information.
3. Read the repository names and versions from the **`release-versions.yml`** file.
4. For each repository, it will do the following:
    - If the version is set to "latest," it will fetch the latest tag from the GitHub API.
    - Create a new release on GitHub with the specified tag name, release name, and body message.
    - Retrieve and display the details of the created release.
    - Get the latest commit SHA from the **`main`** branch.
    - Compare the commit SHA of the tag with the latest commit SHA of the **`main`** branch.
    - Display the comparison status, ahead by, and behind by information.
    - Append the release information to the CSV file (**`ReleaseCreation.csv`**).
    - Display a separator between each repository's output.
5. If any errors occur during the process, an error message will be displayed.

![image](https://github.com/Leticia-Mendes/github-actions-release-creation-pipeline/assets/90715443/6a6b96fd-a883-4d91-b49c-a38be974ea76)


## **Output**

The pipeline generates the following artifacts:

- **ReleaseCreation.csv**: This file contains the release information for each repository, including the repository name, version/tag, release name, published date, target branch, comparison status, and commit differences.
![image](https://github.com/Leticia-Mendes/github-actions-release-creation-pipeline/assets/90715443/813ba310-7fe6-49ae-90f8-db6835365826)



You can access the generated artifacts by navigating to the **Actions** tab, and selecting the completed workflow run. Click on **Sumary** and them click on **ReleaseCreation.csv** to download the artifact:

![image](https://github.com/Leticia-Mendes/github-actions-pipelines/assets/90715443/7e83e310-465c-4713-b1e3-2ac8808836d8)

