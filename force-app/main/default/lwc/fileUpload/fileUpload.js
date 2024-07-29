import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FileUpload extends LightningElement {
    @api acceptedFileTypes; // Getting allowed file types from parent component
    @api maxFiles; // Getting max file count from parent component
    @api remainingFilesCount;

    handleDragOver(event) {
        event.preventDefault();
        this.template.querySelector('.drop-zone').classList.add('dragover');
    }

    handleDragLeave(event) {
        event.preventDefault();
        this.template.querySelector('.drop-zone').classList.remove('dragover');
    }

    handleDragZoneClick(event) {
        if (this.checkRemainingFiles(event)) {
            event.preventDefault();
        }
    }

    handleDrop(event) {
        event.preventDefault();
        this.template.querySelector('.drop-zone').classList.remove('dragover');

        if (this.checkRemainingFiles()) {
            return;
        } else {
            const files = event.dataTransfer.files;
            this.processFiles(files);
        }
    }

    handleChange(event) {
        if (this.checkRemainingFiles()) {
            this.resetFileInput();
            return;
        } else {
            const files = event.target.files;
            this.processFiles(files);
            this.resetFileInput();
        }
    }

    handleUploadClick() {
        if (this.checkRemainingFiles()) {
            return;
        } else {
            const fileInput = this.template.querySelector('.file-input');
            fileInput.click();
        }
    }

    checkRemainingFiles(event = null) {
        if (this.remainingFilesCount == 0) {
            this.showToast('Warning', 'You have already uploaded the maximum number of files', 'warning');
            if (event) {
                event.preventDefault();
            }
            return true;
        }
        return false;
    }

    processFiles(files) {
        if (files.length === 0) {
            return;
        }

        if (files.length > this.remainingFilesCount) {
            this.showToast('Warning', `You can upload a maximum of ${this.maxFiles} files`, 'warning');
            return;
        }

        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const fileEvent = new CustomEvent('fileupload', { detail: file });
            this.dispatchEvent(fileEvent);
        }
    }

    resetFileInput() {
        const fileInput = this.template.querySelector('.file-input');
        fileInput.value = null;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}