FROM mcr.microsoft.com/powershell:alpine-3.12

COPY entrypoint.sh /entrypoint.sh
COPY CreateRelease1.ps1 /CreateRelease1.ps1

ENTRYPOINT ["sh", "/entrypoint.sh"]
