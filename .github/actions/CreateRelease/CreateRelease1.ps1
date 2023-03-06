$release_name = $env:release_name
$token = $env:token
$user = "leticiaaraujo-mcd"

Install-Module -Name PowerShellForGitHub -Force

$secureString = ($token | ConvertTo-SecureString -AsPlainText -Force)
    $cred = New-Object System.Management.Automation.PSCredential "username is ignored", $secureString
    Set-GitHubAuthentication -Credential $cred
    $secureString = $null # clear this out now that it's no longer needed
    $cred = $null # clear this out now that it's no longer needed

$releaseVersions = Get-Content -Path .\release-versions.yml
foreach ($line in $releaseVersions) {	
	if ($line -match $release_name)
	{
		Write-Host "[$line ] in release-versions.yml matches release_name input [$release_name]"

		$line = ($line -replace '\s+').split(":")
		$repo = $line[0]
		$tag = $line[1]
		Write-Host "repo: " $repo
		Write-Host "tag: " $tag
		
		if ($tag -eq "latest") {
			$latestTag = Get-GitHubRelease -OwnerName $user -RepositoryName $repo -Latest
			$tag = $latestTag.tag_name
			Write-Host "the latest tag is $tag"
			$tag = "12345"
			Write-Host $tag
		}
		New-GitHubRelease -OwnerName $user -RepositoryName $repo -Tag $tag -Body "Message here"
	}
}
