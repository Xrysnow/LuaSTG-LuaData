UpdateHistory={
	[2]={VERSION=0.8104,
		TIME=20181026,
		TEXT={
			[1]={title="一、一些更改：",
				[1]={title="A、player：",
					[1]="1、grzaer的标记擦弹状态的处理不再访问lstg.player.grazer.grazed，而是直接访问self.grazed，同时grazer也多加了一个参数用于player创建时把player自身传给grazer",
					[2]="2、player创建自机的时候，self.grazer=New(grazer,self)相比以前多加了一个参数传进去，即传入自身",
				},
				[2]={title="B、bullet：",
					[1]="1、反弹子弹的逻辑优化了",
				},
				[3]={title="C、boss：",
					[1]="1、boss的一些内容适配了宽屏等其他显示模式",
				},
				[4]={title="D、Reimu：",
					[1]="1、灵梦自机的高速雷现在已适配宽屏等其他显示模式",
				},
				[5]={title="E、launch：",
					[1]="1、如果游戏目录下面有launcher.lua则加载启动器时优先使用这个文件，方便调试（不好的更改）",
					[2]="2、如果游戏目录下面没有data.zip，则不加载，方便测试data（不好的更改）",
				},
				[6]={title="F、editor(data)：",
					[1]="1、穿版子弹适配宽屏等其他显示模式",
				},
			},
			[2]={title="二、新增的功能：",
				[1]={title="A、player：",
					[1]="1、新增AddPlayerToPlayerList(displayname,classname,replayname,pos,_replace)函数，虽然大家不一定用……",
				},
				[2]={title="B、Erenderdebug：",
					[1]="1、新增一个测试用的功能，在游戏载入完成前设置_render_debug设置为true（比如在mod里面加上一行code代码：_render_debug=true）、按下F6可以在游戏画面左下角开启一个部分渲染相关的函数的调用次数计数器，可以用来发现一些潜在的问题（细节：该功能使用时会动态修改游戏的data，一般不会影响游戏循环）",
				},
				[3]={title="C、boss：",
					[1]="1、boss ui设置新增了boss位置指示器的设置",
				},
				[4]={title="D、editor(data)",
					[1]="1、新增RawSetA(unit, accel, angle, navi, maxv)用于直接设置加速度，加速度更新在底层，与现有的SetA有冲突",
				},
			},
		},
	},
	[1]={VERSION=0.8103,
		TIME=20181025,
		TEXT={
			[1]={title="零、概述:",
				[1]="NULL、本次更新合并了ESC的新版本ex+的data层和OLC更新的data代码内容",
			},
			[2]={title="一、拆分core.lua，将core的内容大致分为以下模块存放在lib文件夹里面：",
				[1]="A、Linput：按键部分，负责按键状态储存和更新、按键二进制码到字面值的转换等",
				[2]="B、Lmath：数学部分，包含数学常量、常用数学函数以及随机数系统",
				[3]="C、Lobject：Class、object以及一些对象的更新函数，一些object相关常量也在这里",
				[4]="D、Lresources：包含资源的加载、判断、枚举函数，InClude功能也在这里",
				[5]="E、Lscoredata：玩家存档功能支持",
				[6]="F、Lscreen：world、3d、viewmode以及其他一些游戏画面相关的参数设置",
				[7]="G、Lstage：关卡基础功能",
				[8]="H、Ltask：task系统以及一些拓展的task函数，各种骚气的曲线运动都在里面",
				[9]="I：Ltext：文字渲染函数",
			},
			[3]={title="二、拆分ext.lua：",
				[1]="A、ext：负责重载游戏全局回调函数，提供暂停菜单、关卡组和replay支持",
				[2]="B、ext_pause_menu：负责暂停菜单逻辑更新和绘制，暂停菜单资源加载",
				[3]="C、ext_replay：replay系统，stage.Set函数重载",
				[4]="D、ext_stage_group：关卡组功能，关卡组逻辑",
			},
			[4]={title="三、新增的功能：",
				[1]={title="A、Linput：",
					[1]="1、新增KeyCodeToName，负责按键二进制码到字面值的转换",
				},
				[2]={title="B、Lobject：",
					[1]="1、新增InitAllClass，用于整理所有class的回调函数，用于底层调用",
				},
				[3]={title="C、Lscreen：",
					[1]="1、新增ResetScreen，用于刷新screen的各种参数，切换分辨率时可以调用",
					[2]="2、world的默认参数交给Lscreen的DEFAULT_WORLD（private）管理",
					[3]="3、新增OriginalSetDefaultWorld和SetDefaultWorld，用于设置默认world参数",
					[4]="4、新增GetDefaultWorld，可以获得默认world参数",
					[5]="5、新增ResetWorld，可以重置world的参数回默认world参数（然而javastage有自己的一套重置机制……）",
					[6]="6、world的原始参数存放在RAW_DEFAULT_WORLD（private）内，只读",
					[7]="7、RawGetDefaultWorld可获得world的原始参数",
					[8]="8、RawResetWorld可重置world的参数回原始world参数",
				},
				[4]={title="D、ext：",
					[1]="1、ext.time_slow_level现在可以更改了（然而是坏事）",
				},
				[5]={title="E、ext_pause_menu：",
					[1]="1、暂停菜单被独立出来，通过ext.pausemenu.New可以创建一个暂停菜单，当然本质是一个表",
					[2]="2、新增ext.pausemenu.init、ext.pausemenu.frame、ext.pausemenu.render函数，以后暂停菜单的初始化、更新、绘制可以很方便地在其他地方重载了，不需要再去覆盖FrameFunc和AfterRender",
					[3]="3、暂停菜单设置self.kill为true后，会在执行完当前的帧逻辑后被清除（设置为nil）",
				},
				[6]={title="F：Lscoredata：",
					[1]="1、新增InitScoreData，用于创建存档目录、加载玩家存档",
				},
				[7]={title="G：core：",
					[1]="1、新增ResetLstgtmpvar接口，清除lstg.tmpvar用，如果日后还有别的临时关卡内全局变量需要清理，可以在这里添加",
				},
			},
			[5]={title="四、一些更改：",
				[1]={title="A、bent laser：",
					[1]="1、擦弹部分采用了新增的CollisionCheckWidth方法，_data已去除（可能会有潜在对老mod的兼容性问题？）",
					[2]="2、重写消亡（其实是改回来了）为创建新消亡object特效，并在消亡特效object中释放曲光data数据，如果制作者在制作曲线激光的时候继承了曲线激光类又重载了kill和del回调函数，把默认操作删了，则需要手动释放曲光的data，否则仍会驻留在内存中（以后会改善……）",
					[3]="3、曲线激光的消亡特效会按照原曲线激光的混合模式和颜色设置混合模式和颜色",
				},
				[2]={title="B、core和se：",
					[1]="1、原core里面的PlaySound函数和默认音效音量大小的表被挪到se.lua里面，虽然可能会造成编辑器启动失败，但是目前未发现问题",
				},
				[3]={title="C、boss：",
					[1]="1、把boss ex的死亡爆炸特效的第二波爆炸声加上了",
				},
				[4]={title="D、music：",
					[1]="1、把menu和menu_old这两个重复而且没用到的红魔乡标题曲去除了",
				},
				[5]={title="E：编辑器：",
					[1]="1、现在boss的行走图加载交给行走图系统完成，不再生成一大坨代码（然而后果就是行走图资源运行时加载，导致boss出场时会卡死几帧）",
					[2]="2、修复了boss符卡填入符卡名时打包出错的问题",
				},
				[6]={title="F：启动器：",
					[1]="1、启动器的start_game函数里面更新screen、class、scoredata等均通过新增的一些函数完成",
					[2]="2、启动器的keycodetoname现由新增函数完成",
				},
				[7]={title="G：core：",
					[1]="1、被肢解了",
					[2]="2、一些操作交给新增函数完成，比如screen、class、scoredata等",
				},
				[8]={title="H：ext：",
					[1]="1、被分尸了",
					[2]="2、RenderFunc的BeginScene、BeforeRender、AfterRender、EndScene被挪到了if外面，现在每帧都会执行",
				},
				[9]={title="I：bullet：",
					[1]="1、现在消弹特效能正确地在宽屏等其他大小下显示了",
				},
				[10]={title="J：player：",
					[1]="1、现在玩家的丢雷特效player_spell_mask能正确地在宽屏等其他大小下显示了",
				},
			},
			[6]={title="五、底层的一些更新：",
				[1]="警告：非官方更新！仅作为ESC的开发者预览版3出来前的一些过渡",
				[2]="A、Lstg层升级了luajit版本，现在luajit版本为2.1.0b3（旧版为2.0.3），理论上可以更好地兼容win7和win10系统，jit失败的情况可能会减少，性能也许会有所提升",
				[3]="B、Lstg层跟进了ESC新开发的CollisionCheckWidth方法，现在曲线激光的擦弹判定是用该方法完成的",
			},
		},
	},
}