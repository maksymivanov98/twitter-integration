import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { publish, MessageContext} from 'lightning/messageService';
import msgService from '@salesforce/messageChannel/tweetMessageChannel__c';
import createTwitterAuthorizationURL from '@salesforce/apex/CreateTweetController.createTwitterAuthorizationURL';
import createTwitterAuthorizationURLOAuth1 from '@salesforce/apex/CreateTweetController.createTwitterAuthorizationURLOAuth1';
import sendTweet from '@salesforce/apex/CreateTweetController.sendTweet';
import isAccessTokenValid from '@salesforce/apex/CreateTweetController.isAccessTokenValid';
import isAccessTokenOAuth1Valid from '@salesforce/apex/CreateTweetController.isAccessTokenOAuth1Valid';
import logoutOfTwitter from '@salesforce/apex/CreateTweetController.logoutOfTwitter';
import uploadMedia from '@salesforce/apex/CreateTweetController.uploadMedia';
import createAttachmentToTweet from '@salesforce/apex/CreateTweetController.createAttachmentToTweet';
import initUploadVideo from '@salesforce/apex/CreateTweetController.initUploadVideo';
import appendUploadVideo from '@salesforce/apex/CreateTweetController.appendUploadVideo';
import finalizeUploadVideo from '@salesforce/apex/CreateTweetController.finalizeUploadVideo';
import noAccessImage from '@salesforce/resourceUrl/No_Access_Image';

export default class CreateTweet extends LightningElement {
    noAccessImage = noAccessImage;
    @track tweetText = '';
    @track userData = {name:'', username:''};
    @track isUserAuthorized = false;
    @track isUserAuthorizedOAuth1 = false;
    @track statusMessage = '';
    @track isCheckingAuthorization = false;
    @track mediaFiles = [];
    @track hasVideoFiles = false;
    @track isSendingTweet = false;
    @track uploadedFiles = [];
    @track maxFiles = 4;
    @track remainingFilesCount = 4;
    _recordId;

    @wire(MessageContext)
    messageContext

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.isAccessTokenValid();
            this.isAccessTokenOAuth1Valid();
        }
    }

    isAccessTokenValid() {
        this.statusMessage = 'Checking your authorization. Please wait...';
        this.isCheckingAuthorization = true;

        isAccessTokenValid({ contactId: this.recordId })
            .then(result => {
                this.isCheckingAuthorization = false;
                this.isUserAuthorized = result.isSuccess;
                if(result.isSuccess){
                    this.userData.name = result.responseObj.name;
                    this.userData.username = result.responseObj.username;
                }else{
                    this.statusMessage = result.message;
                }
            })
            .catch(error => {
                this.isCheckingAuthorization = false;
                this.isUserAuthorized = false;
                console.log(error.body.message);
            });
    }

    isAccessTokenOAuth1Valid() {
        isAccessTokenOAuth1Valid({ contactId: this.recordId })
            .then(result => {
                if(result.isSuccess){
                    this.isUserAuthorizedOAuth1 = true;
                }else{
                    this.isUserAuthorizedOAuth1 = false;
                }
            })
            .catch(error => {
                console.log(error.body.message);
            });
    }

    handleTweetTextChange(event) {
        this.tweetText = event.target.value;
    }

    handleTwitterAuth() {
        createTwitterAuthorizationURL({ contactId: this.recordId })
            .then(result => {
                this.redirectToLoginPage(result);
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred during Twitter authorization: ' + error.message, 'error');
            });
    }

    handleTwitterAuthOAuth1(){
        createTwitterAuthorizationURLOAuth1({ contactId: this.recordId })
            .then(result => {
                this.redirectToLoginPage(result);
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred during Twitter authorization: ' + error.message, 'error');
            });
    }

    handleLogoutOfTwitter(){
        logoutOfTwitter({ contactId: this.recordId })
        .then(result => {
            if(result.isSuccess){
                this.isUserAuthorized = false;
                this.isUserAuthorizedOAuth1 = false;
                const msgMessage = { message: 'authorization' };
                publish(this.messageContext, msgService, msgMessage);
                this.showToast('Success', 'Twitter logout successful', 'success');
            }else{
                this.showToast('Error', 'An error occurred during Twitter logout: ' + result.message, 'error');
            }
        })
        .catch(error => {
            this.showToast('Error', 'An error occurred during Twitter logout: ' + error.message, 'error');
        });
    }

    redirectToLoginPage(redirectUrl) {
        window.location.href = redirectUrl;
    }

    handlePost() {
        this.isSendingTweet = true;
        this.statusMessage = 'Sending a tweet...';
    
        const mediaTwitterIds = [];
        const mediaDetails = [];
        const videoFiles = this.mediaFiles.filter(file => file.type.startsWith('video/'));
        const uploadPromises = this.mediaFiles.map(file => this.uploadMediaByType(file)
            .then(result => {
                if (result.isSuccess) {
                    mediaTwitterIds.push(result.responseObj.media_id_string);
                    if (!file.type.startsWith('video/')) {
                        mediaDetails.push({
                            name: file.name,
                            type: file.type,
                            mediaBase64: result.responseObj.mediaBase64
                        });
                    }
                } else {
                    throw new Error(result.message);
                }
            })
            .catch(error => {
                this.showToast('Error', `An error occurred while uploading media: ${error.message}`, 'error');
                throw error;
            })
        );
    
        Promise.allSettled(uploadPromises)
            .then(results => {
                const allUploadsSuccessful = results.every(result => result.status === 'fulfilled');
                if (!allUploadsSuccessful) {
                    this.isSendingTweet = false;
                    return Promise.reject('Uploads failed');
                }
    
                if (videoFiles.length > 0) {
                    const largestVideoSizeMB = Math.max(...videoFiles.map(file => file.size / (1024 * 1024)));
                    const delayTime = Math.max(largestVideoSizeMB / 1.5, 20) * 1000;
                    console.log('Pause before sending tweet: ' + delayTime + ' ms');
                    return this.delay(delayTime);
                }
                return Promise.resolve();
            })
            .then(() => sendTweet({
                contactId: this.recordId,
                tweetText: this.tweetText,
                mediaTwitterIdsJSON: JSON.stringify(mediaTwitterIds)
            }))
            .then(result => {
                if (result.isSuccess) {
                    const createAttachmentPromises = mediaDetails.map(detail => {
                        return createAttachmentToTweet({
                            tweetId: result.responseObj,
                            mediaDetailsJSON: JSON.stringify(detail)
                        });
                    });
    
                    return Promise.all(createAttachmentPromises);
                } else {
                    console.log('message: ' + result.message);
                    this.showToast('Error', result.message, 'error');
                    throw new Error(result.message);
                }
            })
            .then(() => {
                this.showToast('Success', 'Tweet posted successfully!', 'success');
                this.isSendingTweet = false;
                const msgMessage = { message: 'tweet' };
                publish(this.messageContext, msgService, msgMessage);
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                console.log(`An error occurred: ${error.message}`);
                this.isSendingTweet = false;
            });
    }
    

    uploadMediaByType(file) {
        if (file.type.startsWith('image/')) {
            return this.uploadImage(file);
        } else if (file.type.startsWith('video/')) {
            return this.uploadVideo(file);
        }
    }

    async uploadImage(file) {
        try {
            const base64 = await this.readFileAsBase64(file);
            const uploadImageResponse = await uploadMedia({
                mediaBase64: base64,
                mediaName: file.name,
                mediaType: file.type,
                contactId: this.recordId
            });

            if (!uploadImageResponse.isSuccess) {
                throw new Error(`An error occurred while loading the media file: ${uploadImageResponse.message}`);
            }

            uploadImageResponse.responseObj.mediaBase64 = base64;
            return uploadImageResponse;

        } catch (error) {
            return { isSuccess: false, message: error.message };
        }
    }

    async uploadVideo(file) {
        try {
            if (!file || !file.size) {
                throw new Error('Invalid file object');
            }

            const initResponse = await initUploadVideo({ mediaType: file.type, totalBytes: file.size, contactId: this.recordId });
            if (!initResponse.isSuccess) {
                throw new Error(`An error occurred while loading the media file: ${initResponse.message}`);

            }

            const mediaId = initResponse.responseObj.media_id_string;
            const chunkSize = 2.7 * 1024 * 1024;
            const totalChunks = Math.ceil(file.size / chunkSize);
            let segmentIndex = 0;

            for (let start = 0; start < file.size; start += chunkSize) {
                const chunk = file.slice(start, start + chunkSize);
                const base64Chunk = await this.readFileAsBase64(chunk);
                const appendResponse = await appendUploadVideo({ mediaId, videoChunk: base64Chunk, segmentIndex, contactId: this.recordId });

                if (!appendResponse.isSuccess) {
                    throw new Error('Failed to append video chunk');
                }
                console.log(`Sent chunk ${segmentIndex + 1} of ${totalChunks}`);
                segmentIndex++;
            }

            const finalizeResponse = await finalizeUploadVideo({ mediaId, contactId: this.recordId });
            if (!finalizeResponse.isSuccess) {
                throw new Error('Failed to finalize video upload');
            }

            return finalizeResponse;

        } catch (error) {
            return { isSuccess: false, message: error.message };
        }
    }

    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                resolve(base64);
            };
            reader.onerror = () => reject(new Error('Error reading file'));
            reader.readAsDataURL(file);
        });
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    
    handleUserClick() {
        const url = `https://x.com/${this.userData.username}`;
        window.open(url, '_blank');
    }

    handleCancel() {
        this.tweetText = '';
        this.dispatchEvent(new CloseActionScreenEvent());
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

    get remainingFileSlots() {
        return this.remainingFilesCount - this.uploadedFiles.length;
    }

    handleFileUpload(event) {
        const file = event.detail;
        const isImage = file.type.startsWith('image/');
        const isVideo = file.type.startsWith('video/');
        const maxImageSize = 5 * 1024 * 1024;
        const maxVideoSize = 50 * 1024 * 1024;
    
        if ((isImage && file.size > maxImageSize) || (isVideo && file.size > maxVideoSize)) {
            const message = 'The maximum image size can be 5 MB. The maximum video size can be 50 MB';
            this.showToast('Warning', message, 'warning');
            return;
        }
    
        file.isVideo = isVideo;
        this.uploadedFiles = [...this.uploadedFiles, file];
        this.processFiles([file]);
    }
    
    processFiles(files) {
        this.mediaFiles = [...this.mediaFiles, ...files];
        this.checkForVideoFiles();
    }

    removeFile(event) {
        const index = event.currentTarget.dataset.index;
        this.uploadedFiles = this.uploadedFiles.filter((file, idx) => idx !== parseInt(index));
        this.mediaFiles = this.mediaFiles.filter((file, idx) => idx !== parseInt(index));
        this.checkForVideoFiles();
    }

    checkForVideoFiles() {
        this.hasVideoFiles = this.mediaFiles.some(file => file.type.startsWith('video/'));
    }
}