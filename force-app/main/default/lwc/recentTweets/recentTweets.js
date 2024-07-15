import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTweets from '@salesforce/apex/RecentTweetsController.getTweets';
import deleteTweet from '@salesforce/apex/RecentTweetsController.deleteTweet';
import getTweetCount from '@salesforce/apex/RecentTweetsController.getTweetCount';
import isAccessTokenValid from '@salesforce/apex/CreateTweetController.isAccessTokenValid';
import createTwitterAuthorizationURL from '@salesforce/apex/CreateTweetController.createTwitterAuthorizationURL';
import noAccessImage from '@salesforce/resourceUrl/No_Access_Image';
import emptyImage from '@salesforce/resourceUrl/Empty_Image';

export default class RecentTweets extends LightningElement {
    noAccessImage = noAccessImage;
    emptyImage = emptyImage;
    @api recordId;
    @track tweets = [];
    @track pageNumber = 1;
    @track pageSize = 3;
    @track totalTweets = 0;
    @track disablePrevious = true;
    @track disableNext = true;
    @track isUserAuthorized = false;
    @track statusMessage = '';
    @track isCheckingAuthorization = false;
    @track isTweetsLoaded = false;

    connectedCallback() {
        this.checkAccessToken();
    }

    checkAccessToken() {
        this.statusMessage = 'Checking your authorization. Please wait...';
        this.isCheckingAuthorization = true;

        isAccessTokenValid({ contactId: this.recordId })
            .then(result => {
                this.statusMessage = result.message;
                this.isUserAuthorized = result.isSuccess;
                this.isCheckingAuthorization = false;

                if (this.isUserAuthorized) {
                    this.fetchTweetCount();
                    this.fetchTweets();
                }
            })
            .catch(error => {
                this.isCheckingAuthorization = false;
                this.statusMessage = error.body.message;
                this.isUserAuthorized = false;
            });
    }

    fetchTweetCount() {
        getTweetCount({ contactId: this.recordId })
            .then(result => {
                this.totalTweets = result;
                this.updatePagination();
            })
            .catch(error => {
                console.error(error);
            });
    }

    fetchTweets() {
        getTweets({ contactId: this.recordId, pageNumber: this.pageNumber, pageSize: this.pageSize })
            .then(result => {
                this.tweets = result.map(tweet => ({
                    ...tweet,
                    formattedDate: this.formatDate(tweet.Tweet_Date__c)
                }));
                this.updatePagination();
                this.isTweetsLoaded = true;
            })
            .catch(error => {
                this.isTweetsLoaded = true;
                console.error(error);
            });
    }

    handleDelete(event) {
        const tweetId = event.target.dataset.id;
        deleteTweet({ tweetId })
            .then(result => {
                if(result.isSuccess){
                    this.fetchTweetCount();
                    this.fetchTweets();
                    this.showToast('Success', 'Tweet deleted successfully', 'success');
                }else{
                    this.showToast('Error', result.message, 'error');
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
            this.fetchTweets();
        }
    }

    handleNext() {
        if (this.pageNumber * this.pageSize < this.totalTweets) {
            this.pageNumber += 1;
            this.fetchTweets();
        }
    }

    updatePagination() {
        this.disablePrevious = this.pageNumber === 1;
        this.disableNext = this.pageNumber * this.pageSize >= this.totalTweets;
    }

    formatDate(dateStr) {
        const date = new Date(dateStr);
        const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        const day = date.getDate();
        const month = monthNames[date.getMonth()];
        return `${day} ${month}`;
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