# iOS-Develop-Tools
## 介绍

本项目是记录一些作者日常开发工具，包括耗时监控、启动优化、崩溃收集等。

## 目录

- [全局耗时监控](/iOSDevelopTools/IOSDevelopTools/OCTimeConsumeMonitor)

  通过Hook objc_msgSend的方式，实现对所有OC方法的前后插桩统计耗时，具体可看作者之前的文章 [通过objc_msgSend实现iOS方法耗时监控](https://juejin.im/post/5e678c526fb9a07c994bf1d8)

- [二进制重排收集工具](/iOSDevelopTools/AppCallCollecter)

  链接器提供了一个 `Order File` 配置，可让我们按自己的需要设置 App 启动时链接库的顺序，对启动优化做到“毫秒必究”。原理及使用参见 [iOS启动优化之二进制重排](https://juejin.im/post/5e92bd826fb9a03c585c003f)。

  

## 版权声明

* 所有原创文章(未进行特殊标识的均属于原创) 的著作权属于 **SimonYe**。
* 所有转载文章(标题注明`[转]`的所有文章) 的著作权属于原作者。
* 所有译文文章(标题注明`[译]`的所有文章) 的原文著作权属于原作者，译文著作权属于 **SimonYe**。

#### 转载注意事项

除注明外，所有文章均采用 [Creative Commons BY-NC-ND 4.0（自由转载-保持署名-非商用-禁止演绎）](http://creativecommons.org/licenses/by-nc-nd/4.0/deed.zh)协议发布。

你可以在非商业的前提下免费转载，但同时你必须：

* 保持文章原文，不作修改。
* 明确署名，即至少注明 `作者：SimonYe` 字样以及文章的原始链接，且不得使用 `rel="nofollow"` 标记。
* 商业用途请联系邮箱 `128526@qq.com` 或微信 `yhbxqc`。
* 微信公众号转载一律不授权 `原创` 标志。