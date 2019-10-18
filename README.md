## About this work

<p align="left">
Most recent studies on deep learning based speech enhance-ment (SE) focused on improving denoising performance. However, successful SE applications require striking a desirable balance between denoising performance and computational cost in real scenarios. In this study, we propose a novelparameter pruning (PP) technique, which removes redundant channels in a neural network. In addition, a parameter quan-tization (PQ) technique was applied to reduce the size of aneural network by representing weights with fewer  clustercentroids. Because the techniques are derived based on dif-ferent concepts, the PP and PQ can be integrated to provideeven  more compact SE models. The experimental resultsshow that the PP and PQ techniques produce a compactedSE model with a size of only  9.76% compared to that of the original model, resulting in minor performance losses from 0.85 to 0.84 for STOI and from 2.55 to 2.52 for PESQ. The promising results suggest that the PPand PQ techniques can be used in an SE system in devices with limited storage and computation resources.

## PP & PQ schematic

### PP
We found high redundancies in the channels of the well trained FCN layers, which provides similar latent information of a input testing speech. Thus, we define a threshold for sparsity to prune these redundant channels, and the process is like the graph below: 
![image](https://github.com/WilliamYu1993/ICSE/blob/master/images/pruning_overall.png)
as shown in (c.), we used a "soft pruning" technique which retrains the model at some specific number of pruning rate. This allows the channels adjuist its latent behavior better after pruning. 

### PQ

The PQ process, the making of code book is shown in the graph below:
![image](https://github.com/WilliamYu1993/ICSE/blob/master/images/Kmeans.png)


### Integration of PP & PQ
The best setup of PP PQ combination which we proposes is shown in the graph below: 
![image](https://github.com/WilliamYu1993/ICSE/blob/master/images/process.png)


### Experimental Results
The integration of these two approaches achieved 10 times model compression ratio with minor performance drop, like:
- PESQ
![image](https://github.com/WilliamYu1993/ICSE/blob/master/images/PESQ_PP%26PQ%26FQ.png)
- STOI
![image](https://github.com/WilliamYu1993/ICSE/blob/master/images/STOI_PP%26PQ%26FQ.png)

## ICSE technical summary

### (A) Training/Testing environment setup

- Conda 8.0
- tensorflow-gpu 1.4.0
- Python 2.7
- Keras 1.1
- Nvidia GTX-1080Ti

```markdown
How to use the TIMIT_FCN_MSE.py

- Get python 2.7 environment
- Install Keras 1.1 (if you already have later version of Keras, please reinstall this version). 
- Fill in the GPU that is being used (default = 0, for 1 GPU computation resource, -1 for no CPU computation resource).
- Fill in the paths of the data expected to train/test with.
- Command: python TIMIT_FCN_MSE.py, you will get the model used in this work.
- This baseline model follows the settings in Fu, et.al's FCN.
```
### (B) Baseline models

Normally, the [FCN](https://github.com/JasonSWFu/End-to-end-waveform-utterance-enhancement/) learning curve of this model will be like the following graph:
![image](https://github.com/WilliamYu1993/ICSE/blob/master/images/Learning_curve_FCNN_TIMIT_MSE.png)

The model we used in the following experiments can be found [here](https://github.com/WilliamYu1993/ICSE/tree/master/Models).

### (C)Dataset 
In this paper, we used [TIMIT dataset](https://drive.google.com/drive/folders/1ojewtLskFCr5Q264EPByPUt11uYKC8mL?usp=sharing) as our training and testing corpus.

### (D)Additional Experimental Results

#### - Denoising task on different datasets:
| Data Set           | Method                | PESQ       | STOI      |
| ------------------ |:---------------------:| ----------:|----------:|
| CHiME-2            | Noisy                 | 1.95       |    0.60   |
| CHiME-2            | FCN                   | 2.03       |    0.75   |
| CHiME-2            | PP+PQ (8x compressed) | 2.01       |    0.74   |
| MHINT              | Noisy                 | 1.54       |    0.81   |
| MHINT              | FCN                   | 2.17       |    0.86   |
| MHINT              | PP+PQ (10x compressed)| 2.08       |    0.84   |

#### - Denoising+Dereverberation joint training/testing:
##### Denoising & Dereverberation Test
![image](https://github.com/WilliamYu1993/ICSE/blob/master/images/Denoise%26Dereverb.PNG)

### (E)Evaluation Metrics
We adopt PESQ and STOI to evaluate the proposed ICSE. The tools we used can be found [here](https://github.com/WilliamYu1993/ICSE/tree/master/Evaluation). 

### (F) Computational Cost
The results show that the computation loads in terms of simulated cycles is reduced from 23,821,318 to 19,084,879 (1.25 times)
, and in terms of FLOPs is reduced from 0.6M FLOPs to 0.48M FLOPs per input size (arbitrary length of a speech utterance). The [Results](https://github.com/WilliamYu1993/ICSE/tree/master/model_cycles_simulation) are computed by [ARM software simualtion](https://github.com/ARM-software/SCALE-Sim).

### (G) Q&A
#### Q1: Explain Fig. 4 PESQ up, STOI down?
A1:The inconsistent trends of PESQ and STOI have been reported in many speech enhancement studies [r1.1, r1.2, r1.3, r1.4, r1.5]. Based on our experience, we found that PESQ scores are more related to signal smoothness, and STOI are more related to speech structures' completeness. Since the PP technique is performed to reduce the redundant components in the FCN model, the enhanced speech become smoother, thus increasing the PESQ scores, while losing delicate speech structures, thus reducing the STOI scores. Due to the page limitation on the published paper, we provide discussions here.

#### Q2: The sparsity thresholding (4) seems arbitrary without giving any motivation, justification or reference. Please provide at least one of them.
A2: This research simulates a real single channel SE, where the distribution of speech samples has a zero mean and a particular standard deviation. As a result, the values of weights in irredundant convolutional channels are larger than the mean absolute values (MAV) in each filter. On the other hand, the values of weights in redundant channels are smaller than its corresponding MAV. We analyzed all weights in each channels in a statistical manner, and accordingly determined the threshold values and pruned out redundant channels based on the determined threshold value.
Additionally, since this strategy was inspired by the reference of [17], C.-T. Liu, et. al., “Computation-performance optimization of convolutional neural networks with redundant kernel removal”, we have added the reference in the paragraph:
“We estimates the redundancy based on the sparsity [17] of each channel in a filter.”

