# -*- coding: utf-8 -*-
"""
Created on Thu 23:33 04/11/2019

@author: Cheng Yu
"""

import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from keras.models import Sequential, model_from_json
from keras.layers.core import Dense, Dropout, Flatten, Activation, SpatialDropout2D, Reshape, Lambda
from keras.layers.normalization import BatchNormalization
from keras.layers.advanced_activations import ELU, PReLU, LeakyReLU
from keras.layers.convolutional import Convolution1D
from keras.optimizers import SGD
from keras.callbacks import ModelCheckpoint
from keras import backend as K
from scipy.io import wavfile

import pdb
import scipy.io
import librosa
import os
os.environ["CUDA_VISIBLE_DEVICES"]="" #Your GPU number, default = 0
import time  
import numpy as np
import numpy.matlib
import random
random.seed(999)

Num_traindata=30000 
epoch=60
batch_size=1

valid_portion = 570

def creatdir(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)

def get_filepaths(directory):
    """
    This function will generate the file names in a directory 
    tree by walking the tree either top-down or bottom-up. For each 
    directory in the tree rooted at directory top (including top itself), 
    it yields a 3-tuple (dirpath, dirnames, filenames).
    """
    file_paths = []  # List which will store all of the full filepaths.

    # Walk the tree.
    for root, directories, files in os.walk(directory):
        for filename in files:
            # Join the two strings in order to form the full filepath.
            filepath = os.path.join(root, filename)
            if filepath.split('/')[-2] != '-15db' and filepath.split('/')[-2] != '-10db':
                file_paths.append(filepath)  # Add it to the list.
    return file_paths  # Self-explanatory.     

def data_generator(noisy_list, clean_path, shuffle = "False"):
    index=0
    while True:     

         rate, noisy = wavfile.read(noisy_list[index])
         noisy=noisy.astype('float')         
         if len(noisy.shape)==2:
             noisy=(noisy[:,0]+noisy[:,1])/2       
    
         noisy=noisy/np.max(abs(noisy))
         noisy=np.reshape(noisy,(1,np.shape(noisy)[0],1))
         
         rate, clean = wavfile.read(clean_path+noisy_list[index].split('/')[-1])
         clean=clean.astype('float')  
         if len(clean.shape)==2:
             clean=(clean[:,0]+clean[:,1])/2

         clean=clean/np.max(abs(clean))         
         clean=np.reshape(clean,(1,np.shape(clean)[0],1))
         
         
         index += 1
         if index == len(noisy_list):
             index = 0
             if shuffle == "True":
                random.shuffle(noisy_list)
                       
         yield noisy, clean 

######################### Training data #########################
Train_Noisy_lists = get_filepaths("")#training noisy set
Train_Clean_paths = "" # training clean set

Train_lists = []
Valid_lists = []

for ind in range(60):
    
    train_temp = Train_Noisy_lists[ind*600:ind*600+valid_portion]
    valid_temp = Train_Noisy_lists[valid_portion*(ind+1):valid_portion*(ind+1)+30]
    Train_lists.extend(train_temp)
    Valid_lists.extend(valid_temp) 

random.shuffle(Train_lists)

Train_lists=Train_lists[0:Num_traindata]      # Only use subset of whole corpus

steps_per_epoch = (Num_traindata)//batch_size

######################### Test_set #########################
Test_Noisy_lists  = get_filepaths("") #testing noisy set
Test_Clean_paths = "" # testing clean set 
                        
Num_testdata=len(Test_Noisy_lists)   


           
start_time = time.time()

print ('model building...')

model = Sequential()


model.add(Convolution1D(30, 55, border_mode='same', input_shape=(None,1)))
model.add(BatchNormalization(mode=2,axis=-1))
model.add(LeakyReLU())

model.add(Convolution1D(30, 55,  border_mode='same'))
model.add(BatchNormalization(mode=2,axis=-1))
model.add(LeakyReLU())

model.add(Convolution1D(30, 55,  border_mode='same'))
model.add(BatchNormalization(mode=2,axis=-1))
model.add(LeakyReLU())

model.add(Convolution1D(30, 55,  border_mode='same'))
model.add(BatchNormalization(mode=2,axis=-1))
model.add(LeakyReLU())

model.add(Convolution1D(30, 55,  border_mode='same'))
model.add(BatchNormalization(mode=2,axis=-1))
model.add(LeakyReLU())

model.add(Convolution1D(30, 55,  border_mode='same'))
model.add(BatchNormalization(mode=2,axis=-1))
model.add(LeakyReLU())

model.add(Convolution1D(30, 55,  border_mode='same'))
model.add(BatchNormalization(mode=2,axis=-1))
model.add(LeakyReLU())

model.add(Convolution1D(1, 55,  border_mode='same'))
model.add(Activation('tanh'))

model.compile(loss='mse', optimizer='adam')
    
with open('FCN_TIMIT_MSE.json','w') as f:    # save the model
    f.write(model.to_json()) 
checkpointer = ModelCheckpoint(filepath='FCN_TIMIT_MSE.hdf5', verbose=1, save_best_only=True, mode='min')  
    
print('training...')
g1 = data_generator(Train_lists, Train_Clean_paths, shuffle = "True")
g2 = data_generator(Valid_lists, Train_Clean_paths, shuffle = "False")
                            					
hist=model.fit_generator(g1,    
                         samples_per_epoch=Num_traindata, 
                         nb_epoch=epoch, 
                         verbose=1,
                         validation_data=g2,
                         nb_val_samples=Num_testdata,
                         max_q_size=1, 
                         nb_worker=1,
                         pickle_safe=True,
                         callbacks=[checkpointer]
                         )                                              

tStart = time.time()

print('load model')
MdNamePath='' #the model path
with open('/mnt/intern/user_chengyu/ICSE/FCN/Eval/TIMIT_FCNN.json', "r") as f:
    model = model_from_json(f.read());
        
model.load_weights(MdNamePath+'.hdf5');
model.summary()
print(K.floatx())
print('testing...')
for path in Test_Noisy_lists: # Ex: /mnt/Nas/Corpus/TMHINT/Testing/Noisy/car_noise_idle_noise_60_mph/b4/1dB/TMHINT_12_10.wav
    S=path.split('/') 
    noise=S[-4]
    speaker=S[-3]
    dB=S[-2]    
    wave_name=S[-1]
    
    rate, noisy = wavfile.read(path)
    noisy=noisy.astype('float32')
    if len(noisy.shape)==2:
        noisy=(noisy[:,0]+noisy[:,1])/2
   
    noisy=noisy/np.max(abs(noisy))
    noisy=np.reshape(noisy,(1,np.shape(noisy)[0],1))

    enhanced=np.squeeze(model.predict(noisy, verbose=0, batch_size=batch_size))
    enhanced=enhanced/np.max(abs(enhanced))
    enhanced=enhanced.astype('float32')
    creatdir(os.path.join("FCN_TIMIT_MSE_wav", noise, speaker, dB))
    librosa.output.write_wav(os.path.join("FCN_TIMIT_MSE_wav", noise, speaker, dB, wave_name), enhanced, 16000)
tEnd = time.time()
print "It cost %f sec" % (tEnd - tStart)

# plotting the learning curve
TrainERR=hist.history['loss']
ValidERR=hist.history['val_loss']
print('@%f, Minimun error:%f, at iteration: %i' % (hist.history['val_loss'][epoch-1], np.min(np.asarray(ValidERR)),np.argmin(np.asarray(ValidERR))+1))
print('drawing the training process...')
plt.figure(2)
plt.plot(range(1,epoch+1),TrainERR,'b',label='TrainERR')
plt.plot(range(1,epoch+1),ValidERR,'r',label='ValidERR')
plt.xlim([1,epoch])
plt.legend()
plt.xlabel('epoch')
plt.ylabel('error')
plt.grid(True)
plt.show()
plt.savefig('Learning_curve.png', dpi=150)


end_time = time.time()
print ('The code for this file ran for %.2fm' % ((end_time - start_time) / 60.))

