# gRemote + Interpolation 踩坑笔记

## OpenCV4.3.0 `make install` 后默认不会产生 .pc 文件

手写 Makefile 时候遇到的问题。假设我们要编译一个用到了 OpenCV 的文件，一般在 Makefile 里常常这么搞

```makefile
INCLUDE = $(shell pkg-config opencv4 --cflags)
LIBS = $(shell pkg-config opencv4 --libs)
OBJECTS = main.o
SOURCE = main.cpp
BIN = app

$(BIN) : $(OBJECTS)
	g++ -o $(BIN) $(OBJECTS) $(LIBS)

$(OBJECTS) : $(SOURCE)
	g++ -c $(SOURCE) $(INCLUDE)

.PHONY:
clean:
	rm -f app *.o
```

然而，你会发现 `pkg-config --cflags` 和 `pkg-config --libs` 根本输不出你要的东西。

查看 `/usr/local/lib/pkgconfig/`，发现里面没有 `opencv.pc` 或 `opencv4.pc`。

这是因为 OpenCV4.3.0 已经不会在 `sudo make install` 的时候产生 .pc 文件并且将其放到对应的位置了！

需要在 cmake 的时候加上 `-D OPENCV_GENERATE_PKGCONFIG=ON` 才会这么做。

另外，默认生成的文件是 `opencv4.pc` 而不是 `opencv.pc`，所以传给 `pkg-config` 的应该是 `opencv4` 而不是 `opencv`。
