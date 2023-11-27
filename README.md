# DS_Queue_client_part

*name: Rundong Yang*

*username at HIS: b23runya*

## 0. Intro

I'm responsible for writing client part. Given my programing experience, I chose to use [Dart](https://en.wikipedia.org/wiki/Dart_(programming_language)) language(Dart SDK version: 3.1.0 (stable) (Tue Aug 15 21:33:36 2023 +0000) on "windows_x64") and the [Flutter](https://en.wikipedia.org/wiki/Flutter_(software)) frame to implement the client. Considering there're many similar functions between supervisor client and student client, I intergrated them together into one software.

Given flutter is cross-platform and open-sourced, theoretically you can compile one same source code into many platforms' softwares, such as windows, android, web, linux, iOS and even mac os x.

 ## 1. Configuration(windows)

1. First of all, you need to follow [Install | Flutter](https://docs.flutter.dev/get-started/install) this guide to install your flutter environment, for exaple, windows.

2. You can get the source code from [my github repository](https://github.com/JSYRD/ds_queue_studentclient).

3. Enter the root directory of the project, and run `flutter run`.

4. Follow the guide to select your target device (windows, for example).

5. Wait until it automatically resolve the dependencies and start running.

6. Close the running program.

7. Enter the directory: `(project_name)/build/windows/runner/Debug`, and then rename the file `libzmq-v142-mt-4_3_5.dll` to `zmq.dll`

   > This is an typo error of the plugin's script, and I can't fix it because I'm not the owner of the plugin.

8. Now you can run the program by simple `flutter run` at the root.

* The software running by this way is a Debug version one. Actually no difference between the Release version.
* If you want to use the Release version software, you can simply run `dart run msix:create` at the root directory. After compiling finished, you'll find some files in `(project_name)/build/widnows/runner/Release`.
  * The `.msix` is the installer. You can simply double click it and install it into your PC.
  * Or, you can also rename the file as the same in step 7, and then directly run the `.exe` file, or compress all of the files in the directory except the `.msix` one. (INCLUDING data folder!) And release it as a compressed file.

## 2. About the ZMQ and other dependencies

Actually, flutter can automatically resolve all of the dependencies needed. But as I subscripted above, one of the zmq plugin requires a zmq dll file, and has some error about it. Luckily the file itself is working well, so only renaming it is needed.

# DS_Queue_server_part

*name: Leon Pfeil*

*username at HIS: b23leopf*

##1
the server is written in java 17 (coretto-17 17.0.2) and uses gradle. refer to build.grade for the dependencies
configuration, and compilation was done with the default settings of IntelliJ. 

For the execution of the source code execute the main in Main.ServerMain
To execute the .jar open the Server/Jar directory and execute the following command in the CMD : java -cp "ZMQ Server.jar" Main.ServerMain

Code also at https://github.com/MrSloth1/ZMQServer



# 3. API

See [API.md](./API.md).