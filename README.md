#### Notes

1. If you build a qemu image, minify the resulting image with:  
    cd output-qemu
    mv image.qcow2 image.qcow2.big
    qemu-img -O qcow2 -c image.qcow2.big image.qcow2
    rm image.qcow2.big

2. To only build a certain image run :
    packer build -only=qemu template.json
    packer build -only=vmware-iso template.json
    packer build -only=virtualbox-iso template.json
