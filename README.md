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

需要在 cmake 的时候加上 `-D OPENCV_GENERATE_PKGCONFIG=ON` 它才会这么做。

另外，默认生成的文件是 `opencv4.pc` 而不是 `opencv.pc`，所以传给 `pkg-config` 的应该是 `opencv4` 而不是 `opencv`。

## OpenCV4.3.0 中存在与 X11 内相同名字的符号，同时 include 会引起冲突

具体情况请看这个[link](https://github.com/opencv/opencv/issues/7113)，总之在编译的时候会出现这些信息

```text
In file included from /usr/local/include/opencv4/opencv2/opencv.hpp:86:0,
                 from mod_app.cpp:9:
/usr/local/include/opencv4/opencv2/stitching.hpp:58:4: warning: #warning Detected X11 'Status' macro definition, it can cause build conflicts. Please, include this header before any X11 headers. [-Wcpp]
 #  warning Detected X11 'Status' macro definition, it can cause build conflicts. Please, include this header before any X11 headers.
    ^~~~~~~
In file included from /usr/include/GL/glx.h:30:0,
                 from include/libs.h:64,
                 from include/main.h:16,
                 from mod_app.cpp:6:
/usr/local/include/opencv4/opencv2/stitching.hpp:152:10: error: expected identifier before ‘int’
     enum Status
          ^
In file included from /usr/local/include/opencv4/opencv2/opencv.hpp:86:0,
                 from mod_app.cpp:9:
/usr/local/include/opencv4/opencv2/stitching.hpp:153:5: error: expected unqualified-id before ‘{’ token
     {
     ^
```

这是因为 X11 中的 Status 这个符号和 OpenCV 的 Status 产生了冲突。这个链接里面说在 OpenCV 之前 include X11 的库会解决这个问题，然而我试了试并没有啥用。

整个 gRemote 中似乎并没有直接用到过这个 Status，所以我直接在 `libs.h` 里这么做

```cpp
#undef Status
#include <opencv2/opencv.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/optflow.hpp>
#include <opencv2/core.hpp>
```

暂时好像没啥问题（另外似乎只有 `mod_app.cpp` 里有 include X11 的库文件。

这当然不是好的解决方案，而且奇怪的是，`mod_app.cpp` 里明明是在我一开始放 `#include <opencv2/opencv.hpp` 后面才有 `#include <X11/Xlib.h>`，但是前面的语句会先于后面的语句报错？

总之这个问题有待深入考察。

## mod_app 中的共享内存会自动释放吗？

这大概不能算是个坑......只是个疑问。

## cv::cuda::GpuMat::upload 第一次调用的时候速度很慢

在 `interpolator.cpp` 中第一次调用 `cv::cuda::GpuMat::upload` 的时候速度很慢。后面调用的速度就快了很多。这是因为第一次调用 cuda 函数的时候，需要初始化 CUDA context。

详细请看这个链接。[link](https://stackoverflow.com/questions/19454373/too-slow-gpumat-uploading-of-an-small-image/40069778)

