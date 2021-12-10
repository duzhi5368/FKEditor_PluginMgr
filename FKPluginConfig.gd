# extends "res://addons/FKEditor_PluginMgr/PluginMgrFramework.gd"
extends "./addons/FKEditor_PluginMgr/Scripts/PluginMgrFramework.gd"


func _plugging():
	pass
"""
	# 默认情况下载指定仓库的 /addons 目录
	plug("duzhi5368/FKEditor_GDScriptMacro")
	# 下载不同的 Branch
	plug("duzhi5368/FKEditor_GDScriptMacro", {"branch": "demo"})
	# 下载指定的 Tag
	plug("duzhi5368/FKEditor_GDScriptMacro", {"tag": "1.0.0-stable"})
	# 下载指定的 Commit
	plug("duzhi5368/FKEditor_GDScriptMacro", {"commit": "6dd9642f913051de0d3fb994e58e838d7a88971a"})

	# 指定是开发模式的插件，可以使用 “production” 命令进行删除
	plug("duzhi5368/FKEditor_GDScriptMacro", {"dev": true})

	# 指定下载并显示更新细节
	plug("duzhi5368/FKEditor_GDScriptMacro", {"on_updated": "_on_update_detail"})

	# 下载指定仓库中的 指定目录（默认是下载 addons 下的数据）
	plug("duzhi5368/FKEditor_GDScriptMacro", {"include": ["decalco/"]})
	# 不包含 addons 目录，整个仓库都是一个 addons 内数据时使用。
	plug("duzhi5368/FKEditor_GDScriptMacro", {"install_root": "addons/FKEditor_GDScriptMacro", "include": ["."]})

	# 下载 GITLAB
	plug("https://gitlab.com/duzhi5368/FKEditor_GDScriptMacro")
	# 下载本地 GIT仓库
	plug("file:///D/Godot/local-project/.git")

	# 测试更新命令
	connect("updated", self, "_on_plugin_updated")

func _on_updated(plugin):
	match plugin.name:
		"duzhi5368/FKEditor_GDScriptMacro": print("Use upgrade command!")

func _on_update_detail(plugin):
	print("%s updated" % plugin.name)
	print("Installed files: " + plugin.dest_files)

func _on_plugin_updated(plugin):
	print("%s post update hook with signal" % plugin.name)
"""
