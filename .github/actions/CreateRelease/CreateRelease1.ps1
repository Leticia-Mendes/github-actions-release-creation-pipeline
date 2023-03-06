$release_name = $env:release_name
$token = $env:token
$user = "leticiaaraujo-mcd"


function Main {
	Get-Modules 
  Get-Credentials
	$releaseVersionsValues = Get-ReleaseVersionsFile
	GenerateRelease $releaseVersionsValues
}

function Get-Modules{
	Install-Module powershell-yaml -Force
	Install-Module -Name PowerShellForGitHub -Force 
}

function Get-Credentials {
	$secureString = ($token | ConvertTo-SecureString -AsPlainText -Force)
	$cred = New-Object System.Management.Automation.PSCredential "username is ignored", $secureString
	Set-GitHubAuthentication -Credential $cred
	$secureString = $null # clear this out now that it's no longer needed
	$cred = $null # clear this out now that it's no longer needed
}

function Get-ReleaseVersionsFile {
	$fileReleaseVersions = Get-Content -Path ".\release-versions.yml"
	$content = ''
	foreach ($line in $fileReleaseVersions) { 
		$content = $content + "`n" + $line 
	}
	$releaseVersions = ConvertFrom-YAML $content
	$releaseVersionsValues = $releaseVersions.Values
	return $releaseVersionsValues	
}

function GenerateRelease($releaseVersionsValues) {
	foreach ($repo in $releaseVersionsValues.Keys) {	
		$tag = $releaseVersionsValues.Item($repo)
		Write-Host "RepoName: " $repo " - Tag: " $tag
		if ($tag -eq "latest") {
			$latestTag = Get-GitHubRelease -OwnerName $user -RepositoryName $repo -Latest
			$tag = $latestTag.tag_name
			Write-Host "The latest tag for the repository $repo is $tag"
			$tag = $tag + ".0"
			write-host "The new tag for the repository $repo is $tag"
		}
	
		New-GitHubRelease -OwnerName $user -RepositoryName $repo -Name $release_name -Tag $tag -Body "Message here :) "
		Write-Host "The $release_name release was generated with $tag tag for the $repo repository."
		Write-Host "-------------------------------"
	}
}

Main
