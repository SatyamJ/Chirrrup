# Project - *Chirrrup - Twitter Client*

**Chirrrup - Twitter Client** is a basic twitter app to read and compose tweets the [Twitter API](https://apps.twitter.com/).

Time spent: **130** hours spent in total

## User Stories

The following functionality is completed:

- [x] User can sign in using OAuth 1.0a protocols login flow with a web view
- [x] User can view tweets from their home timeline, user timeline,  
- [x] The current signed in user will be persisted across restarts
- [x] In the home timeline, user can view tweet with the user profile picture, username, tweet text, timestamp and image(if available)
- [x] Retweeting and favoriting should increment the retweet and favorite count.
- [x] User should be able to unretweet and unfavorite and that should decrement the retweet and favorite count.
- [x] Tweet Details Page: User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [x] Profile page:
    - [x] Contains the user header view
    - [x] Contains a section with the users basic stats: # tweets, # following, # followers
- [x] Home Timeline: Tapping on a user image should bring up that user's profile page
- [x] Compose Page: User can compose a new tweet by tapping on a compose button.
- [x] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.
- [x] User can pull to refresh.
- [x] When composing, you should have a countdown in the upper right for the tweet limit.
- [x] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [x] User can see tweets with images supporting dynamic resizing of table cells
- [x] Slide-out menu to sign-out and switch between home and profile screen 
- [x] User can see dynamic change of time interval units i.e. either hours or minutes or seconds as applicable 
- [x] Identifying the embedded links in the tweet and making it clickable
- [x] App handles all the error conditions gracefully 

The following features are some future enhancements:
- [ ] Profile Page
    - [ ] Implement the paging view for the user description.
    - [ ] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
    - [ ] Pulling down the profile page should blur and resize the header image.
- [ ] Account switching
    - [ ] Long press on tab bar to bring up Account view with animation
    - [ ] Tap account to switch to
    - [ ] Include a plus button to Add an Account
    - [ ] Swipe to delete an account

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='https://github.com/SatyamJ/Chirrrup/blob/master/demo.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright [2016] [Satyam Jaiswal]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
