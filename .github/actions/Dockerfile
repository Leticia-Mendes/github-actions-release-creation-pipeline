FROM mcr.microsoft.com/powershell:alpine-3.12

COPY entrypoint.sh /entrypoint.sh
COPY releaseCreation.ps1 /releaseCreation.ps1

ENTRYPOINT ["sh", "/entrypoint.sh"]
