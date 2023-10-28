---
sidebar_position: 1
---

# Introduction
### Why?
I was inspired to make LuaClass based off of Java classes. The reality is that most classes now are just "tables" in Lua. You still have to define a `.new` method every time you want to make a class, as well as its methods, and you have no control over some things without making a "cluttered" integration.

### Installation
To get started, you must have [Wally](https://wally.run/) installed on your machine, and make sure that you are able to use it in your command line.

Initialize your project with Wally using the following command (if you have not already)
```bash
wally init
```

Next, install **LuaClass**. To do this, head over to your newly created `wally.toml` file, and add the following where applicable.
```toml
[dependencies]
Class = "mnmzc/LuaClass@1.0.3"
```