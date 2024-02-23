# Gitea Server

The service is used for the following purposes:

- local cache for public git services which may not stable in some regions
- git server for small teams

## Quick Start

add backup url to backup_url.txt,

```txt
path/to/gitea
```

then run the following commands,

```powershell
docker compose up -d
schedule.ps1
```
