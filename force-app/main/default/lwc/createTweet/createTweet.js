import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import createTwitterAuthorizationURL from '@salesforce/apex/CreateTweetController.createTwitterAuthorizationURL';
import sendTweet from '@salesforce/apex/CreateTweetController.sendTweet';
import isAccessTokenValid from '@salesforce/apex/CreateTweetController.isAccessTokenValid';
import uploadMedia from '@salesforce/apex/CreateTweetController.uploadMedia';
import noAccessImage from '@salesforce/resourceUrl/No_Access_Image';

export default class CreateTweet extends LightningElement {
    noAccessImage = noAccessImage;
    @track tweetText = '';
    @track name = '';
    @track username = '';
    @track isUserAuthorized = false;
    @track statusMessage = '';
    @track isCheckingAuthorization = false;
    @track mediaFiles = [];
    @track mediaId = null;
    @track fileName = '';
    @track errorMessage = '';
    _recordId;

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.isAccessTokenValid();
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
                    this.name = result.responseObj.name;
                    this.username = result.responseObj.username;
                }else{
                    this.statusMessage = result.message;
                }
                console.log(JSON.stringify(result.responseObj));
            })
            .catch(error => {
                this.isCheckingAuthorization = false;
                this.errorMessage = error.body.message;
                this.isUserAuthorized = false;
            });
    }

    handleTweetTextChange(event) {
        this.tweetText = event.target.value;
    }

    handleFilesChange(event) {
        this.mediaFiles = event.target.files;
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

    redirectToLoginPage(redirectUrl) {
        window.location.href = redirectUrl;
    }

    handlePost() {
        const promises = [];
        const mediaTwitterIds = [];
        const mediaDetails = [];

        for (let i = 0; i < this.mediaFiles.length; i++) {
            const file = this.mediaFiles[i];
            promises.push(this.readFileAsBase64(file).then(base64 => {
                return uploadMedia({
                    mediaBase64: base64,
                    mediaName: file.name,
                    mediaType: file.type,
                    contactId: this.recordId
                }).then(result => {
                    if (result.isSuccess) {
                        mediaTwitterIds.push(result.responseObj.media_id_string);
                        mediaDetails.push({
                            name: file.name,
                            type: file.type,
                            base64: base64
                        });
                    }
                });
            }));
        }

        Promise.all(promises)
            .then(() => {
                const mediaTwitterIdsJSON = JSON.stringify(mediaTwitterIds);
                const mediaDetailsJSON = JSON.stringify(mediaDetails);
                return sendTweet({ contactId: this.recordId, tweetText: this.tweetText, mediaTwitterIdsJSON: mediaTwitterIdsJSON, mediaDetailsJSON: mediaDetailsJSON });
            })
            .then(() => {
                this.showToast('Success', 'Tweet posted successfully!', 'success');
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred while posting the tweet: ' + error.message, 'error');
            });
    }

    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => {
                resolve(reader.result.split(',')[1]);
            };
            reader.onerror = () => {
                reject(reader.error);
            };
            reader.readAsDataURL(file);
        });
    }

    handleUserClick() {
        const url = `https://x.com/${this.username}`;
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
}