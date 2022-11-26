# set up config
modify ScriptConfig.json <br>
leave gitInstall.inf alone, unless you want to mess with default installation of git
# run script 
* open powershell with RunAsAdministrator and run this 
`Set-ExecutionPolicy -RemoteSigned` this is needed for scripts to run, else it will complain that you are not allowed to run scripts on this system.
* `.\SetUpUserForSuccess.ps1` 
* enjoy 

```

https://github.com/bikerdba/ForKush

from url : https://testplan.readthedocs.io/en/latest/getting_started.html
Using a virtualenv
Installation using a virtualenv:

Install git.

Install python.

Open the windows command prompt.

Install pip.

C:\path\to\installed\interpreter\python.exe get-pip.py
Install virtualenv.

pip install virtualenv
Create a virtualenv.

virtualenv -p C\:path\to\installed\interpreter\python.exe testplan-oss
cd testplan-oss
.\Scripts\activate
Clone testplan repo.

git clone https://github.com/morganstanley/testplan.git
cd testplan
Install dependecies and setup.

# Skip heavy dependencies but miss some functionality.
pip install -r requirements-basic.txt
python setup.py develop --no-deps
python install-testplan-ui
````
