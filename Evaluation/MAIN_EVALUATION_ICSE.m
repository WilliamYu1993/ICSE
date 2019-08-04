function title_flag=EVALUATION_MAIN(indir1,indir2,indir3,outdir,outfilename,title_flag)

% indir1: document path for clean data
% indir2: document path for noisy data
% indir3: document path for enhanced data
% outdir: document path for evaluated results

if nargin == 5
    title_flag=1;
end

if  indir1(end) == filesep
    indir1=indir1(1:(end-1));
end
if  indir2(end) == filesep
    indir2=indir2(1:(end-1));
end
if  indir3(end) == filesep
    indir3=indir3(1:(end-1));
end

if  strcmp(outdir(end),'\') || strcmp(outdir(end),'/')
    outdir=outdir(1:(end-1));
end

if exist(outdir) ~=7
    mkdir(outdir);
end

filelist_1=dir(indir1);
filelist_2=dir(indir2);
filelist_3=dir(indir3);
filelist_len=length(filelist_1);

for k=3:filelist_len
    [pathstr_1,filenamek_1,ext_1] = fileparts(filelist_1(k).name);
    [pathstr_2,filenamek_2,ext_1] = fileparts(filelist_2(k).name);
    [pathstr_3,filenamek_3,ext_1] = fileparts(filelist_3(k).name);
    if filelist_1(k).isdir
        title_flag=EVALUATION_MAIN([indir1 filesep filenamek_1],[indir2 filesep filenamek_2],[indir3 filesep filenamek_3],outdir,outfilename,title_flag);
    else
        
        CleanDataFile=fullfile(indir1, filelist_1(k).name);
        NoisyDataFile=fullfile(indir2, filelist_2(k).name);
        EnhadDataFile=fullfile(indir3, filelist_3(k).name);
        
        [TCleanData,fc]=audioread(CleanDataFile);
         %TCleanData = TCleanData/max(abs(TCleanData));
        [TNoisyData,fn]=audioread(NoisyDataFile);
         %TNoisyData = TNoisyData/max(abs(TNoisyData));
        [TEnhadData,fe]=audioread(EnhadDataFile);
         TEnhadData = TEnhadData/max(abs(TEnhadData));
        %TNoisyData = TNoisyData*2;
        
        %minimum_points=min([length(TCleanData),length(TNoisyData),length(TEnhadData)]);
        
        %TCleanData=TCleanData/std(TCleanData(1:minimum_points));
        %TNoisyData=TNoisyData/std(TNoisyData(1:minimum_points));
        %TEnhadData=(TEnhadData*10)/std(TEnhadData(1:minimum_points)*10);
        
        %x = (length(TEnhadData)-length(TCleanData));
        %x = x/2;
        %longitude = length(TEnhadData);
        %longitude = longitude - x;
        %Idx = x+1 : longitude;
        %TEnhadData=(TEnhadData(Idx));
        %TNoisydata=(TNoisyData(Idx));
        
        %minimum_points = length(TCleanData);
        minimum_points=min([length(TCleanData),length(TNoisyData),length(TEnhadData)]);
        Idx=1:minimum_points;
        
        CleanData=(TCleanData(Idx));%/std(TCleanData(Idx)));
        NoisyData=(TNoisyData(Idx));%/std(TNoisyData(Idx)));
        EnhadData=(TEnhadData(Idx));
        
        %audiowrite(CleanDataFile,CleanData,fe);
        %audiowrite(NoisyDataFile,NoisyData,fe);
        %audiowrite(EnhadDataFile,EnhadData,fe);
        
        % for HASQI used!
        HL = [0, 0, 0, 0, 0, 0];
        eq = 2;
        Level1 = 65;
        % for SSNR
        len=256; % frame length
       %STOI
        stoi_scor(k-2) = stoi(CleanData, EnhadData, fn);  
        
       % SSNR
        if((length(NoisyData) == length(EnhadData)))
             ssnr_dB(k-2)=ssnr(EnhadData,NoisyData,CleanData,len);
        %    ssnr_dB(k-2)=1;
        end
        
       %PESQ
        pesq_mos(k-2)=pesq(CleanDataFile, EnhadDataFile); %pesq.m
        %copyfile(CleanDataFile,'cln_1.wav');
        %copyfile(EnhadDataFile,'enh_1.wav');
        %switch fe
        %    case 8000
        %        [Return,strout]=system('E:\E_evaluation_2\pesq +8000 cln_1.wav enh_1.wav');
        %    case 16000
        %        [Return,strout]=system('E:\E_evaluation_2\pesq +16000 cln_1.wav enh_1.wav');
        %end
        %c=strfind(strout,'Prediction : PESQ_MOS = ');
        %pesq_mos(k-2)=str2double(strout(c+23:c+28));
        %pesq_mos(k-2)=pesq_o(CleanDataFile, EnhadDataFile);
        
        %Writing process
        if title_flag == 1
            fw=fopen(sprintf('%s%s%s.txt',outdir,filesep,outfilename),'wb');
            if fw ~= -1
                fprintf(fw,'%20s:\t%7s\t%8s\t%8s\n','EVALUATED METHODS','PESQ','STOI','SSNRI');
                title_flag=0;
            else
                disp('Error: Cannot open the text file. Stop.');
                break;
            end
        end
        
        %'PESQ','HASQI','HASPI','SDI','STOI','SSNR'
        if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
            fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\n',filelist_1(k).name,pesq_mos(k-2),stoi_scor(k-2),ssnr_dB(k-2));
        else
            fprintf(fw,'%20s:\t%f\t%f\n',filelist_1(k).name,pesq_mos(k-2),stoi_scor(k-2),ssnr_dB(k-2));
        end
        
    end
end
    if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
         mean_ssnr=mean(ssnr_dB);
         std_ssnr=std(ssnr_dB);
    %     mean_ssnr=1;
    %     std_ssnr=1;
    end
    mean_pesq=mean(pesq_mos);
    std_pesq=std(pesq_mos);
    mean_stoi=mean(stoi_scor);
    std_stoi=std(stoi_scor);
    
    %Writing process
    %'PESQ','HASQI','HASPI','SDI','STOI','SSNR'
    if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
        fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\n','Mean',mean_pesq,mean_stoi,mean_ssnr);
        fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\n','Stad',std_pesq,std_stoi,std_ssnr);
    else
        fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\n','Mean',mean_pesq,mean_stoi,mean_ssnr);
        fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\n','Stad',std_pesq,std_stoi,std_ssnr);
    end
    fclose(fw);

end