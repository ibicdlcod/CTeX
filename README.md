CTeX Maintenance Plan  
====
如何编译:  
1. 下载启用 Advance Log 的 NSIS 3.0b3 http://prdownloads.sourceforge.net/nsis/nsis-3.0b3-log.zip?download  
2. 执行以下命令： `makensis.exe /INPUTCHARSET UTF8 /OUTPUTCHARSET UTF8 /DDEBUG filename.nsi`  
3. 若需详细编译过程可使用 /V4 开关，但是会严重影响编译速度  
4. 若需发布则去掉 /DDEBUG 开关，并 install\Full 下面的文件夹移动到 install 下，删除所有的dummy.txt

目前已完成：  
- [x] 所有脚本UTF-8化  
- [x] 包含最新版的 Ghostview 和 GSView  
- [x] 加入 WinEdt 9.1 科学版（你懂的，可直接使用无需定期reset） （是否其他编辑器比如 TeX Studio？）  
- [x] 重绘图标（偷懒不加上 CTeX 字样了）
- [x] 重绘安装包的 Banner    
- [x] 支持从最新一个版本的升级（对于 MikTeX 其实是删除重装）
- [x] 再次重建目录结构（现在的 install 目录即要被打包的文件，但为了加快打包测试速度所有目录都是空的，真正的文件都在 Full 目录下，正式打包时移动即可）

待完成或问题：  
- [ ] 加入MiKTeX 的必要部分（等待 Liam 的宏包列表） 
- [ ] 处理原本有的 Addons 目录（是否继续包含？如果要，是否有可以升级的部分？）
- [ ] 现在的 CTeX-Build 工具无法正常运行，报错但没有Log。详见 https://github.com/Harry-Chen/CTeX-Tools