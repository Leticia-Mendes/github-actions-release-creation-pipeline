FROM mcr.microsoft.com/powershell:alpine-3.12

COPY entrypoint.sh /entrypoint.sh
COPY CreationRelease.ps1 /CreationRelease.ps1

ENTRYPOINT ["sh", "/entrypoint.sh"]
