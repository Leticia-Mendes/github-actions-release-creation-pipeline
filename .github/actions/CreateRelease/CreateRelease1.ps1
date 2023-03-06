$release_name = $env:release_name
$token = $env:token
$user = "Leticia-Mendes"
$date = Get-Date -Format MM-dd-yyyy


function Main {
	Get-Modules 
	Get-Credentials
	New-ReleaseCreationCsvFile
	$releaseVersionsValues = Get-ReleaseVersionsFile
	SetTagAndCreateRelease $releaseVersionsValues
}

function Get-Modules {
	Install-Module powershell-yaml -Force
	Install-Module -Name PowerShellForGitHub -Force 
	Write-Host "Installed Modules"
}

function Get-Credentials {
	$secureString = ($token | ConvertTo-SecureString -AsPlainText -Force)
	$cred = New-Object System.Management.Automation.PSCredential "username is ignored", $secureString
	Set-GitHubAuthentication -Credential $cred
	$secureString = $null
	$cred = $null
}

function New-ReleaseCreationCsvFile {
	New-Item "./ReleaseCreation-$date.csv" -Value "Repository, Version/Tag, Release Name, Date, Branch, Status, `n"
}

function Get-ReleaseVersionsFile {
	$fileReleaseVersions = Get-Content -Path ".\release-versions.yml"
	$content = ''
	foreach ($line in $fileReleaseVersions) { 
		$content = $content + "`n" + $line 
	}
	$releaseVersions = ConvertFrom-YAML $content
	$releaseVersionsValues = $releaseVersions.Values
	Write-Host "Release Versions Values: " $releaseVersionsValues
	Write-Host "-------------------------- " 
	return $releaseVersionsValues	
}

function SetTagAndCreateRelease($releaseVersionsValues) {
	$releaseVersionsValues.Keys | ForEach-Object {
		$repo = $_
		$tag = $releaseVersionsValues.$_
		Write-Host "RepoName: " $repo ", Tag: " $tag	
	
		if ($tag -eq "latest") {
			try {
				$latest = Get-GitHubRelease -OwnerName $user -RepositoryName $repo -Latest
				Write-Host "latest " $latest
				$tag = $latest.tag_name
				Write-Host "latest tag => $tag"
				Write-Host "The latest tag for the repository $repo is $tag"
			}
			catch {
				Write-Host "No release found for $repo repository."
				$tag = $date
				write-host "A new tag $tag will be create for the repository $repo."
			}
		}
		
		try {
			$newRelease = New-GitHubRelease -OwnerName $user -RepositoryName $repo -Name $release_name -Tag $tag -Body "Message here :) "
			Write-Output "New-Release" $newRelease
			$publishDate = $newRelease.published_at
			$branch = $newRelease.target_commitish
			$contentCsvFile = "$repo, $tag, $release_name, $publishDate, $branch,  - "
			Add-Content -Path "./ReleaseCreation-$date.csv" $contentCsvFile
			Write-Output "New release $release_name was created with $tag tag for the $repo repository."
			Write-Host "-------------------------------"
		}
		catch {
			$contentCsvFile = "$repo, has not been created a new release."
			Add-Content "./ReleaseCreation-$date.csv" $contentCsvFile
			Write-Output "A new version has not been created for the $repo repository."
			Write-Host "-------------------------------"
		}
	}
}

Main
