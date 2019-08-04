InputPar.TsInpPrePath ='E:\Ensemble(HDDAE)\CHiME2\Noisy';
%InputPar.TsNoiseType={'babble','car_noise','pink_noise','street_noise'};
%InputPar.TsNoiseType={'BabyCry','Engine','White'};%,'pink_noise','street_noise'};
InputPar.TsNoiseType={'All'};
%InputPar.TsSNR      ={'-12dB','-6dB','0dB','6dB','12dB','18dB'};%, '5db', 'n10db', 'n5db'};
InputPar.TsSNR      ={'n6dB','n3dB','0dB','3dB','6dB','9dB'};%, 'n5db'};

InputPar.TsOutPrePath ='E:\Ensemble(HDDAE)\CHiME2';
EvalFolder ='E:\Ensemble(HDDAE)\CHiME2\score\pesq';
EvalClnPth='E:\Ensemble(HDDAE)\CHiME2\Clean';

cd ''; %the folder of this code

InputPar.runName = {'PQ_FCN_CHiME-2_v3_wav'};
%InputPar.runName = {'K2C_fp32','K4C_fp32','K8C_fp32','K16C_fp32','K32C_fp32','K64C_fp32'};
%InputPar.runName = {'FCNN_sp0.6_int8','FCNN_sp0.65_int8','FCNN_sp0.7_int8','K2C_int8','K4C_int8','K8C_int8','K16C_int8','K32C_int8','K64C_int8','K2C_sp0.6_int8','K2C_sp0.65_int8','K2C_sp0.7_int8','K4C_sp0.6_int8','K4C_sp0.65_int8','K4C_sp0.7_int8','K8C_sp0.6_int8','K8C_sp0.65_int8','K8C_sp0.7_int8','K16C_sp0.6_int8','K16C_sp0.65_int8','K16C_sp0.7_int8','K32C_sp0.6_int8','K32C_sp0.65_int8','K32C_sp0.7_int8','K64C_sp0.6_int8','K64C_sp0.65_int8','K64C_sp0.7_int8'};

for runName_ind=1:length(InputPar.runName) 
    for nstpe_ind=1:length(InputPar.TsNoiseType)
        for nssnr_ind=1:length(InputPar.TsSNR)
        
            fprintf('Noise Type: %s,%s; SNR:%s\n',num2str(nstpe_ind),InputPar.TsNoiseType{nstpe_ind},InputPar.TsSNR{nssnr_ind});
        
            EvalOut =sprintf('%s%s',EvalFolder,filesep,InputPar.runName{runName_ind});mkdir(EvalOut);
            FileName=sprintf('%s_%s',lower(InputPar.TsNoiseType{nstpe_ind}),InputPar.TsSNR{nssnr_ind});
        
            EvaNyPth=sprintf('%s%s%s',InputPar.TsInpPrePath,filesep,InputPar.TsNoiseType{nstpe_ind},filesep,InputPar.TsSNR{nssnr_ind});
            EvaEnPth=sprintf('%s%s%s%s',InputPar.TsOutPrePath,filesep,InputPar.runName{runName_ind},filesep,InputPar.TsNoiseType{nstpe_ind},filesep,InputPar.TsSNR{nssnr_ind});
        
            MAIN_EVALUATION_ICSE(EvalClnPth,EvaNyPth,EvaEnPth,EvalOut,FileName);
        end    
    end
end