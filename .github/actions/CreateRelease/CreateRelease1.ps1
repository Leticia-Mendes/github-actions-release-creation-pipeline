$release_name = $env:release_name
$token = $env:token
$user = "Leticia-Mendes"

function Main {
	Install-Module powershell-yaml -Force
	New-ReleaseCreationCsvFile
	$releaseVersionsValues = Get-ReleaseVersionsFile
	SetTagAndCreateRelease $releaseVersionsValues
}

function New-ReleaseCreationCsvFile {
	New-Item "./ReleaseCreation.csv" -Value "Repository, Version/Tag, Release Name, Date, Branch, Status, Ahead of main, Behind of main, `n"
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

function New-Header() {
	$headers = @{ 
		"Authorization" = "Bearer $token" 
		"Accept" = "application/vnd.github.v3+json"
		"User-Agent" = "PowerShell"
	}
	return $headers
}

function SetTagAndCreateRelease($releaseVersionsValues) {
	$releaseVersionsValues.Keys | ForEach-Object {
		$repo = $_
		$tag_name = $releaseVersionsValues.$_
		try {
			if ($tag_name -eq "latest") {
				$url = "https://api.github.com/repos/$user/$repo/git/refs/tags?ref=refs/heads/main"		
				$headers = New-Header
				$response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

				$position = -1
				$sha_tag = $($response.object.sha)[$position ]
				$tag_name = $($response.ref.split("/"))[$position]
			}
			Write-Host "Repository: $repo, Latest tag: $tag_name, Sha: $sha_tag"

			$url = "https://api.github.com/repos/$user/$repo/releases"
			$bodyData = @{
				tag_name = $tag_name
				name = $release_name
				body = "Message here :)"
			} | ConvertTo-Json
			$response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $bodyData
			$response | Select-Object -Property tag_name, name, published_at, target_commitish, body, draft, prerelease		
			$published_date = $response.published_at
			$target_branch = $response.target_commitish

			# get latest sha main
			$url = "https://api.github.com/repos/$user/$repo/commits/main"
			$response = Invoke-RestMethod -Uri $url -Headers $headers
			$sha_main = $response.sha
			Write-Host "Repository: $repo, Latest sha from main: $sha_main, Sha from tag: $sha_tag"

			# compare latest sha_main x sha_tag 			
			$url = "https://api.github.com/repos/$user/$repo/compare/$sha_main...$sha_tag"
			$status = Invoke-RestMethod -Uri $url -Headers $headers
			Write-Host "comparison between commits: $status"
			Write-Host "Status: $($status.status)"
			Write-Host "Ahead by: $($status.ahead_by)"
			Write-Host "Behind by: $($status.behind_by)"

			$contentCsvFile = "$repo, $tag_name, $release_name, $published_date, $target_branch, $($status.status), $($status.ahead_by), $($status.behind_by) "
			Add-Content -Path "./ReleaseCreation.csv" $contentCsvFile		
			Write-Host "-----------------------------------------"
		}
		catch {
			Write-Host "Something went wrong whit repository $repo ."
		}
	}
}

Main
