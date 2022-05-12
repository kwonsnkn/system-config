# Perforce workspace dir
if [[ $HOSTNAME == "skwon-edge" ]]; then
    export P4_WS=$HOME/Perforce/skwon_edge_01
    export GITLAB_PARTNER=$HOME/Gitlab/gitlab.partner	
    export GITLAB_ENG=$HOME/Gitlab/gitlab.eng	
elif [[ $HOSTNAME == "20HZDW2" ]]; then
    export P4_WS=/work1/p4
    export GITLAB_PARTNER=/work/gitlab/gitlab-partner	
    export GITLAB_ENG=/work/gitlab/gitlab.eng
else
    echo "Unknown host name $HOSTNAME"
fi
export P4CONFIG=.p4config
export GITLAB_BOOTLOADER=$GITLAB_PARTNER/aml-t962-secure/secure_boot_dev

# ROKU NFS BUILD ENV
#export ROKU_NFS_ROOT=${HOME}/nfs/rootfs
export NFSROOT=${HOME}/nfs/reno/rootfs
export ROKU_NFS_IP=`hostname -I | cut -d ' ' -f 1`
export EXPORTROOT=${NFSROOT}

# 
export SEC=${HOME}/Work/Roxton/Security

# Aliases
alias sudo='sudo '

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# chnage monitor source to HDMI (15: DP, 17: HDMI 1, 18: HDMI 2)
alias chmonitorsrc='ddccontrol -r 0x60 -w 17 dev:/dev/i2c-17'

# GPG
function gpgsearch      { gpg --keyserver keymaster.corp.roku.com --search-keys $1; } # $1: userid
function gpgfingerprint { gpg --fingerprint $1; } # gpg --fingerprint <email>
function gpgimport      { gpg --import $1; } # gpg --import <private_key> 
function gpglistsecret  { gpg --list-secret-keys $1; } # $1: email 
function gpglistkeys    { gpg --list-keys --keyid-format LONG; } 
function gpgenc         { gpg --encrypt --sign --armor -r $1 $2; } # $1: email, $2: filename
function gpgdec         { gpg --decrypt $1 > $(echo "$1" | sed -e 's/\.[^.]*$//'); } # $1: filename

# FAST TOOL
function fast-uart-en     { ./fast.py -b AA 06 10 01 A7 EF; }
function fast-src-atv     { ./fast.py -b AA 06 22 00 D4 39; }
function fast-src-av      { ./fast.py -b AA 06 22 01 C4 18; }
function fast-atvch4      { ./fast.py -b AA 07 20 00 04 EA A9; }
function fast-hdmi1       { ./fast.py -b AA 06 25 01 5D 8F; }
function fast-hdmi2       { ./fast.py -b AA 06 25 02 6D EC; }
function fast-test-on     { ./fast.py -b AA 06 29 01 18 E2; }
function fast-test-off    { ./fast.py -b AA 06 29 00 08 C3; }
function fast-test-9block { ./fast.py -b AA 06 2A 00 5D 90; }
function fast-test-white  { ./fast.py -b AA 06 2A 01 4D B1; }

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Channel app debugging
export DEVPASSWORD=ahov

function whichroku
{
  echo "Current Roku Target =" $ROKU_DEV_TARGET
}

function setroku
{
  echo "Previous Roku Target =" $ROKU_DEV_TARGET
  export ROKU_DEV_TARGET=$1
  echo "New Roku Target =" $ROKU_DEV_TARGET
}

# Aliases
alias rokucommander='java -jar /opt/rokucommander/RokuCommander11-linux.jar&'
alias settunnel='ssh -N -f -L 5901:localhost:5901 10.14.24.175'

function saveserial
{
  sudo grabserial -t -v -d /dev/ttyUSB0 -b 115200 -w 8 -p N -s 1 -e 90  | ts "%H:%M:%.S" | tee $1
}

cdscript(){ cd $P4_WS/depot/users/skwon/scripts; }
cdstb()   { cd $P4_WS/depot/edelivery/STB-Client/$1; }
cdmfg()   { cd $P4_WS/depot/firmware/mfg/$1; }
cdrtn()   { cd $P4_WS/depot/firmware/release/$1; }
cdbootloader()   { cd $P4_WS/depot/edelivery/STB-Client/bootloaders/$1; }
cdteeloader()    { cd $P4_WS/depot/edelivery/STB-Client/teeloaders/$1; }
cdroxton()       { cd $GITLAB_PARTNER/aml-t9xx/t9xx; }
cdfirmware()       { cd $GITLAB_ENG/firmware/firmware; }
cdroxtonsecure()       { cd $GITLAB_PARTNER/aml-t962-secure/secure_boot_dev; }
cdsec()       { cd $SEC; }

# DOCKER BUILD
alias docker-bake=$P4_WS/depot/firmware/release/main/os/scripts/docker/localcontainer/docker-bake
alias docker-make=$P4_WS/depot/firmware/release/main/os/scripts/docker/localcontainer/docker-make
alias docker-u20-make=$P4_WS/depot/firmware/release/main/os/scripts/docker/localcontainer/docker-u20-make

# buildfw <branch> <soc vendor> <platform> <branch_name>   <oem-brand>  <os/port/debug/ecc>
#         $1       $2           $3         $4              $5           $6
# buildfw mfg      realtek      reno       reno_9.3.2      tcl-tcl         
# buildfw mfg      realtek      roma       roma_9.3.0      mtc-onn         
# buildfw mfg      mstar        malone     malone2020_mfg  hisense-onn
# buildfw mfg      mtk          athens     athens_mfg_2020 mtc-multiple ecc
# buildfw release  realtek      roma       r10.0.2         mtc-onn      debug
function buildfw
{
	if [[ $# -lt 5 ]]; then
	    echo "Usage:"
            echo "  buildfw <branch> <soc vendor> <platform> <branch_name>   <oem-brand>  <os/port/debug/ecc>"
            echo "  buildfw mfg      realtek      reno       reno_9.3.2      tcl-tcl"
            echo "  buildfw mfg      mtk          athens     athens_mfg_2020 mtc-multiple ecc"
            echo "  buildfw release  realtek      roma       r10.0.2         mtc-onn      debug"
	    return
	fi

	cd $P4_WS/depot/firmware/$1/$4
	#rm dist/rootfs/* -rf
	#rm dist/skeleton/* -rf
	#rm ../port/$2/$3/build-carbon/rootfs/* -rf
	#rm ../port/$2/$3/build-carbon/custom_pkg/* -rf
	if [[ $3 = "roma" ]]; then
	    rm port/$2/rtd2821/$3/build-carbon/rootfs/* -rf
	    rm port/$2/rtd2821/$3/build-carbon/custom_pkg/* -rf
	else
	    rm port/$2/$3/build-carbon/rootfs/* -rf
	    rm port/$2/$3/build-carbon/custom_pkg/* -rf
	fi

	if [[ $6 = "os" ]]; then
            echo "Build os dist-package"
	    cd os
	    rm dist/rootfs/* -rf && \
	    rm dist/skeleton/* -rf && \
	    time make -j$(grep -c processor /proc/cpuinfo) BUILD_PLATFORM=$3 rootfs dist-package |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
	elif [[ $6 = "port" ]]; then
	    if [[ $3 = "roma" ]]; then
                cd port/$2/rtd2821/$3
	    else
                cd port/$2/$3
            fi
	    rm build-carbon/rootfs/* -rf && \
	    rm build-carbon/custom_pkg/* -rf && \
	    #time docker-u20-make -j$(grep -c processor /proc/cpuinfo) BUILD_PLATFORM=$3 OEM_PARTNER=$5 IMAGE_TYPE=acramfs image |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
	    time make -j$(grep -c processor /proc/cpuinfo) BUILD_PLATFORM=$3 OEM_PARTNER=$5 IMAGE_TYPE=acramfs image |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
	elif [[ $6 = "debug" ]]; then
            echo "Build nfs-image"
	    cd os
            export NFSROOT=${HOME}/nfs/$3/rootfs
            export EXPORTROOT=${NFSROOT}
	    time make -j$(grep -c processor /proc/cpuinfo) BUILD_PLATFORM=$3 OEM_PARTNER=$5 STRIP_DEBUG=false PAX_DEBUG=on PAXCTL=paxctl rootfs port-image nfs-make|& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
	elif [[ $6 = "ecc" ]]; then
            echo "Build ECC Image"
	    cd os
            export NFSROOT=${HOME}/nfs/$3/rootfs
            export EXPORTROOT=${NFSROOT}
	    time make -j$(grep -c processor /proc/cpuinfo) BUILD_PLATFORM=$3 OEM_PARTNER=$5 STRIP_DEBUG=false NEW_VENDOR=true rootfs port-image port-build_ecc_file |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
	else
            echo "Build acramfs from os"
	    cd os
            export NFSROOT=${HOME}/nfs/$3/rootfs
	    if [[ $4 = "midland_9.2.0" ]]; then
	        time make -j$(grep -c processor /proc/cpuinfo) BUILD_PLATFORM=$3 OEM_PARTNER=$5 rootfs port-image |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
	    else
	        time make -j$(grep -c processor /proc/cpuinfo) BUILD_PLATFORM=$3 OEM_PARTNER=$5 STRIP_DEBUG=false NEW_VENDOR=true rootfs port-image |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
	    fi
	fi
}

# build reno from git ('platform')
function buildreno
{
cd ~/Gitlab/gitlab.partner/rtd2873/rtd2873/reno
time make -j$(grep -c processor /proc/cpuinfo) ROKU_OS_DIR=~/Gitlab/gitlab.partner/rtd2873/porting_kit/OS/os BUILD_PLATFORM=reno image |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
}

# ecpu (RENO, ROMA) 
# buildecpu <branch>
function buildecpu
{
    if [[ $# -lt 1 ]]; then
        echo "Usage:"
        echo "  buildecpu <branch>"
	echo "  (Examples)"
        echo "  buildecpu reno"
        echo "  buildecpu reno_mfg"
        echo "  buildecpu roma"
        echo "  buildecpu roma_mfg"
	return
    fi

    cd $P4_WS/depot/edelivery/STB-Client/teeloaders/$1
    if [ $1 = "reno" ] || [ $1 = "reno_mfg" ]; then
        echo "$1"
        cd 3rdParty/realtek/R2873/bootcode/emcu
	make
        echo -e "\n[ecpu.bin location]"
	ls -al output/hex/ecpu.bin
        echo -e "\n[copying ecpu.bin to ../pre_uboot/binaries/ ...]"
	cp output/hex/ecpu.bin ../pre_uboot/binaries/
    elif [ $1 = "roma" ] || [ $1 = "roma_mfg" ]; then
        echo "$1"
        cd 3rdParty/realtek/R2853/bootcode/emcu
	make
        echo -e "\n[ecpu.bin location]"
	ls -al output/hex/ecpu.bin
        echo -e "\n[copying ecpu.bin to ../pre_uboot/binaries/ ...]"
	cp output/hex/ecpu.bin ../pre_uboot/binaries/
    fi
}

# Teeloader (RENO, ROMA) 
# buildteeloader <branch>
function buildteeloader
{
    if [[ $# -lt 1 ]]; then
        echo "Usage:"
        echo "  buildteeloader <branch>"
	echo "  (Examples)"
        echo "  buildteeloader reno"
        echo "  buildteeloader reno_mfg"
        echo "  buildteeloader roma"
        echo "  buildteeloader roma_mfg"
	return
    fi

    cd $P4_WS/depot/edelivery/STB-Client/teeloaders/$1
    if [ $1 = "reno" ] || [ $1 = "reno_mfg" ]; then
        echo "$1"
        cd 3rdParty/realtek/R2873/bootcode/bin/RTD287O
	make PRJ=RTD2873_roku
        echo -e "\n[pre_uboot.bin location]"
	ls -al ../../pre_uboot/out/pre_uboot.bin
        echo -e "\n[u_boot.bin location]"
	ls -al ../../uboot/u-boot.bin
    elif [ $1 = "roma" ] || [ $1 = "roma_mfg" ]; then
        echo "$1"
        cd 3rdParty/realtek/R2853/bootcode/bin/RTD285O
	make PRJ=RTD2853_roku
        echo -e "\n[pre_uboot.bin location]"
	ls -al ../../pre_uboot/out/pre_uboot.bin
        echo -e "\n[u_boot.bin location]"
        echo "In Roma, uboot in teeloaders project is obsolete. Please build uboot in 'bootloaders' project"
    fi
}

#Verify pre_uboot.bin.sig , pre_uboot.bin
function verifyteeloader
{
    openssl dgst -sha256 -verify km_key.pem -signature pre_uboot.bin.sig pre_uboot.bin
}

# Bootloader
# buildbootloader <branch>
function buildbootloader
{
    if [[ $# -lt 1 ]]; then
        echo "Usage:"
        echo "  buildbootloader <branch>"
	echo "  (Examples)"
        echo "  buildbootloader reno"
        echo "  buildbootloader roma"
	return
    fi

    cd $P4_WS/depot/edelivery/STB-Client/bootloaders/$1
    if [ $1 = "reno" ] || [ $1 = "bandera" ]; then
        echo "$1"
        cd 3rdParty/realtek/R2873/bootcode/bin/RTD287O
	make PRJ=RTD2873_roku_secure_soc
	# make PRJ=RTD2873_roku (FOR UNSECURE DEVICE)
        echo -e "\n[bootloader build for secure SOC is done]"
	ls -al ../../uboot/u-boot.bin
    elif [ $1 = "roma" ]; then
        echo "$1"
        cd 3rdParty/realtek/R2853/bootcode/bin/RTD285O
	make PRJ=RTD2853_roku
        echo -e "\n[bootloader build for ROMA is done]"
        echo -e "\n[u_boot.bin location]"
	ls -al ./u-boot.bin
    fi
}

# LONGVIEW TEE BUILD
# 1. 'buildlongviewtee'
#      # Need to copy key into /key/ directory (mnkeylongview.mstar)
# 2. Build teeloader (u-boot.bin)
#      # It may be needed to unshelve CL2918262 to address rtlog related error
#      > cd $MYWORKSPACE/depot/edelivery/STB-Client/teeloaders/longview
#      > docker-bake longview t10-uboot-local
# 3. 'cplongviewuboot'
# 4. buildlongviewmain'
#
# [NOTE] NEED TO RUN THE FOLLOWING ONE TIME BEFORE RUNNING buildlongviewtee
#   export LC_ALL=C
#   cd $P4_WS/depot/edelivery/STB-Client/security/mstar/R2/dev/tee_link && \
#   sh ./link_tee_macan.sh 
function buildlongviewtee
{
  export LC_ALL=C
  
  cd $P4_WS/depot/edelivery/STB-Client/security/mstar/R2/dev/tee_build && \
  sh ./build_tee_macan.sh && \
  cp tee/tee_arm.tar.gz ../tee_link/tee/tee_arm.macan.tar.gz && \
  cd $P4_WS/depot/edelivery/STB-Client/security/mstar/R2/dev/tee_link && \
  sh ./link_tee_macan.sh && \
  cp tee/package/tee.bin $P4_WS/depot/edelivery/STB-Client/teeloaders/longview/3rdParty/mstar/t10/mboot/u-boot-2011.06/binaries/roku_tee.bin && \
  cp tee/package/Utility/nuttx_config.bin $P4_WS/depot/edelivery/STB-Client/teeloaders/longview/3rdParty/mstar/t10/mboot/u-boot-2011.06/binaries/roku_nuttx_config.bin
}

function cplongviewuboot
{
  cp $P4_WS/depot/edelivery/STB-Client/teeloaders/longview/oe/oe-core/build-longview/dist/deploy/images/t10/u-boot/u-boot.bin $P4_WS/depot/firmware/release/main/port/mstar/platform/t10/prebuilt/
}


# buildlongviewmfg
# (Build Longview mfg branch (longview_mfg_2018))
function buildlongviewmfg
{
  cd $P4_WS/depot/edelivery/STB-Client/longview2018_mfg
  docker-bake longview roku-image
}

function buildroxton
{
    if [[ $# -lt 1 ]]; then
        echo "Usage:"
        echo "  buildroxton [os|port] [ecc]"
	return
    fi

    if [ $# -eq 2 ] && [ $2 = "ecc" ]; then
        export ECC_BUILD_FLAG="ecc_nand"
    else
        export ECC_BUILD_FLAG=
    fi

    if [ $1 = "os" ]; then
	export NFSROOT=${HOME}/nfs/roxton/rootfs
        cd $GITLAB_ENG/firmware/firmware/os
        # time make -j$(grep -c processor /proc/cpuinfo) BUILD_PLATFORM=roxton rootfs port-image |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
        time make -j$(grep -c processor /proc/cpuinfo) BUILD_PLATFORM=roxton STRIP_DEBUG=false PAX_DEBUG=on rootfs port-image ${ECC_BUILD_FLAG} |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
    elif [ $# -eq 1 ] && [ $1 = "port" ]; then
        cd $GITLAB_PARTNER/aml-t9xx/t9xx/roxton
        #time make -j$(grep -c processor /proc/cpuinfo) ROKU_OS_DIR=../../porting_kit/os/ |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
        #time make -j$(grep -c processor /proc/cpuinfo) ROKU_OS_DIR=../../porting_kit/os/ ecc_nand |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
        time make -j$(grep -c processor /proc/cpuinfo) ROKU_OS_DIR=../../porting_kit/os/ ${ECC_BUILD_FLAG} OEM_PARTNER=cvte-ktc-multiple |& tee ./build-$(date "+%Y-%m-%d-%H:%M:%S").log
    else
        echo "Usage:"
        echo "  buildroxton [os|port]"
        return
    fi
}

function buildroxtonbootloader
{
    if [[ $# -lt 1 ]]; then
        echo "Usage:"
        echo "  buildroxtonbootloader [evt1|evt2] [copy]"
	return
    fi
    cd $GITLAB_BOOTLOADER/bootloader/uboot-repo && \
    ./mk t5d_am301_recovery_v1 --update-bl2 clean && \
    ./mk t5d_am301_recovery_v1 --update-bl2 --tc false --build bootloader -ss bronze && \
    cd ~/Work/Roxton/Security/s2_signing/ && \
    rm bl2*; \
    rm r-uboot.bin; \
    rm random*; \
    rm zeroiv; \
    rm RokuBoot.bin*; \
    cp $GITLAB_BOOTLOADER/bootloader/uboot-repo/fip/_tmp/bl2_fw.bin ~/Work/Roxton/Security/s2_signing/ && \
    cp $GITLAB_BOOTLOADER/bootloader/uboot-repo/fip/_tmp/r-uboot.bin ~/Work/Roxton/Security/s2_signing
    if [[ $1 = "evt1" ]]; then
        #### Sign EVT1 
        echo "./create_bootbin.sh keys_aurora_s2/"
        cp $GITLAB_BOOTLOADER/bootloader/uboot-repo/fip/prebuilt/bl2.hdr.aur ~/Work/Roxton/Security/s2_signing/bl2.hdr
        ./create_bootbin.sh keys_aurora_s2/
        #### COPY RokuBoot.bin 
        if [[ $2 = "copy" ]]; then
            echo "Copy RokuBoot.bin.signed to platform/roxton/prebuilts/RokuBoot.bin.signed_for_evt"
            cp RokuBoot.bin.signed ~/Gitlab/gitlab.partner/aml-t9xx/t9xx/platform/roxton/prebuilts/RokuBoot.bin.signed_for_evt
        fi
    elif [[ $1 = "evt2" ]]; then
        #### Sign EVT2
        echo "./create_bootbin.sh keys_rox_s2/"
        cp $GITLAB_BOOTLOADER/bootloader/uboot-repo/fip/prebuilt/bl2.hdr.rox_s2 ~/Work/Roxton/Security/s2_signing/bl2.hdr
        ./create_bootbin.sh keys_rox_s2/
        #### COPY RokuBoot.bin 
        if [[ $2 = "copy" ]]; then
            echo "Copy RokuBoot.bin.signed to platform/roxton/prebuilts/RokuBoot.bin.signed_for_evt2"
            cp RokuBoot.bin.signed ~/Gitlab/gitlab.partner/aml-t9xx/t9xx/platform/roxton/prebuilts/RokuBoot.bin.signed_for_evt2
        fi
    else
        echo "invalid board type $1"
    fi
    #### BUILD preuboot.bin & preuboot.bin.sig 
    cd $GITLAB_BOOTLOADER/bootloader/uboot-repo && \
    ./mk t5d_am301_recovery_v1 --update-bl2 clean && \
    ./mk t5d_am301_recovery_v1 --update-bl2 --tc false --build teeloader -ss bronze && \
    #### COPY preuboot.bin & preuboot.bin.sig 
    if [[ $2 = "copy" ]]; then
        cd $GITLAB_BOOTLOADER/bootloader/uboot-repo/fip/_tmp/
        cp preuboot.bin ~/Gitlab/gitlab.partner/aml-t9xx/t9xx/platform/br/bootloader/uboot-repo/bl2/bin/t5d/preuboot.bin
        cp preuboot.bin.sig ~/Gitlab/gitlab.partner/aml-t9xx/t9xx/platform/br/bootloader/uboot-repo/bl2/bin/t5d/preuboot.bin.sig
    fi
}

# check compile error in main uboot
function buildroxtonubootdryrun
{
  cd $GITLAB_PARTNER/aml-t9xx/t9xx/platform/br/bootloader/uboot-repo/
  ./mk t5d_am301_v1 clean
  ./mk t5d_am301_v1 
}

# buildroxtonbootloaderforusb evt1/evt2 build
function buildroxtonbootloaderforusb
{
    if [ $# -eq 2 ] && [ $2 = "build" ]; then
        cd $GITLAB_BOOTLOADER/bootloader/uboot-repo && \
        #git checkout user/skwon/bootloader-for-usb-unbrick && \
        cd $GITLAB_BOOTLOADER/bootloader/uboot-repo/bl33/v2015/board/amlogic/t5d_am301_v1/
        rm aml-key ; \
        ln -s ~/Work/Roxton/Security/t5d_signing_tool/keydir-$1 aml-key && \
        cd $GITLAB_BOOTLOADER/bootloader/uboot-repo && \
        ./mk t5d_am301_v1 --update-bl2 clean && \
        echo "./mk t5d_am301_v1 --update-bl2 > build.log" && \
        ./mk t5d_am301_v1 --update-bl2 > build.log && \
        rm ~/Work/Roxton/Security/t5d_signing_tool/input/* ; \
        #cp fip/_tmp/sign_tmp/t5d_am301_v1-u-boot.aml.zip ~/Work/Roxton/Security/t5d_signing_tool/input/ && \
        cd fip/_tmp/
        zip ~/Work/Roxton/Security/t5d_signing_tool/input/t5d_am301_v1-u-boot.aml.zip bl2_new.bin bl30_new.bin bl31.img bl33.bin && \
        cd ~/Work/Roxton/Security/t5d_signing_tool && \ 
        rm keydir ; \
        ln -s ./keydir-$1 keydir &&\
        rm ./output/* ; \
        ./sign.sh
        cat output/u-boot.bin.usb.bl2.signed.encrypted output/u-boot.bin.usb.tpl.unsigned > output/uboot_recovery.bin && \
        cp output/uboot_recovery.bin ~/Work/Roxton/Security/$1_recovery/
        #cp output/u-boot.bin.signed.encrypted ~/Work/Roxton/Security/$1_recovery/uboot_recovery.bin
    elif [ $# -eq 1 ]; then
        cd ~/Work/Roxton/Security/t5d_signing_tool && \
        rm ./input/* && \
        rm ./output/* && \
        cp ./zt_t5d_ops_efuse_check_v1-u-boot.aml.zip ./input/
        rm keydir && \
        ln -s ./keydir-$1 keydir &&\
        ./sign.sh && \
        cat output/u-boot.bin.usb.bl2.signed.encrypted output/u-boot.bin.usb.tpl.unsigned > output/uboot_recovery.bin && \
        cp output/uboot_recovery.bin ~/Work/Roxton/Security/$1_recovery/
    else
        echo "Invalid arguments"
        echo "Usage: buildroxtonbootloaderforusb evt1|evt2 [build]"
    fi
}
