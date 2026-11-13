# LumaLock Studio Suite Workspace

**LumaLock Pro / OptiLock Pro（旧: はむはむ画像圧縮くん）/ ArcLock Pro（旧: かんたんZIP圧縮くん）** のプロ仕様3点セット開発用・統合ワークスペースおよび別マシン引き継ぎ用リポジトリです。

詳しくは **[HANDOVER_MANUAL.md](./HANDOVER_MANUAL.md)** をご覧ください。

## クイックスタート（別マシンでのセットアップ）

### macOS
```bash
git clone https://github.com/mixography-max/lumalock-suite-workspace.git LumaLock_Suite_Workspace
cd LumaLock_Suite_Workspace
chmod +x setup_mac.sh
./setup_mac.sh
```

### Windows (PowerShell)
```powershell
git clone https://github.com/mixography-max/lumalock-suite-workspace.git LumaLock_Suite_Workspace
cd LumaLock_Suite_Workspace
.\setup_windows.ps1
```

セットアップ後、Antigravity で `LumaLock_Suite_Workspace` フォルダ（または `LumaLock_Suite.code-workspace`）を開き、`HANDOVER_MANUAL.md` の引き継ぎプロンプトを貼り付けて作業を再開してください。
