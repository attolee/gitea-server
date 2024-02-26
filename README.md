# Gitea Server

该服务用于以下目的：

- 为在某些地区可能不稳定的公共git服务提供本地缓存
- 适用于小团队的git服务器

## 使用说明

启动服务，然后访问 <http://localhost:3000>

```powershell
docker compose up -d
```

启动定时备份

```powershell
schedule.ps1 path/to/backup
```

从备份恢复

```powershell
docker compose up -d
restore.ps1 path/to/backup
```

手动备份

```powershell
backup.ps1 path/to/backup
```
