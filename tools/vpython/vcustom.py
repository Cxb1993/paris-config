import sys
from visit import *

def sf(fn = "script.py" ):
    ''' save visit state to a python file '''
    print "(vcustom.py) saving: %s" % fn
    f = open(fn, "wt")
    WriteScript(f)
    f.close()

def v():
    ''' run visit gui '''
    OpenGUI("-nosplash", "-noconfig")

def sw(fn = "visit"):
    ''' save png image '''
    import os
    ''' save png image '''
    a = GetSaveWindowAttributes()
    a.family = 0
    a.outputToCurrentDirectory = 1
    h = 1024; w = int(1.2*h)
    a.width  = w
    a.height = h
    a.quality = 100
    a.fileName = fn
    a.format = a.PNG
    a.resConstraint = a.NoConstraint
    SetSaveWindowAttributes(a)
    fn = SaveWindow()
    print "(vcustom.py) saving %s\n" % fn

def go_last():
    lst = TimeSliderGetNStates()-1
    SetTimeSliderState(lst)

del sys.argv[0] # remove vcustom.py
Launch()
execfile(sys.argv[0])
