### Moja-terminal

Moja-terminal is a command line management tool that can install, set key and start moja terminal application.

### Installing moja-terminal

```bash
$ sudo npm install moja-terminal -g
```

Note that you have to install node and npm globally.

### set key

A moja key is a shell name that you can download it and get read the hostname, version, email, publicKey of moja terminal application.

You can set key like that:

```bash
$ moja set-key xxxx
```

You can start moja terminal application like that:

```bash
$ moja start
```
Note that after you set key one minute later,whether you execute the moja start command or not,moja terminal application will start by crontab.
### Download File

After you start moja terminal application, you can download file from moja terminal device like that:

```bash
$ moja download filepath
```

