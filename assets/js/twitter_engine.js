let TwitterEngine = {
    init(socket){
        let channel = socket.channel('twitter_engine:lobby',{})
        channel.join()
        this.listenForSignUp(channel)
        this.subscribe(channel)
        this.tweet(channel)
        this.queryByHash(channel)
        this.queryByMention(channel)
    },

    listenForSignUp(channel){
        document.getElementById('login-form').addEventListener('submit',function(e){
            e.preventDefault()

            let user_name = document.getElementById('user-name')
            // let display_window = document.querySelector("trial_id")
            channel.push('register', {name: user_name.value})
            // user_name.addEventListener("")
            // setting values back to null
            // document.getElementById("myBtn-register").addEventListener("click", displayLive)
            displayLive()
            function displayLive(){
            document.getElementById("trial_id").innerHTML = user_name.value + " has successfully logged in"
            }
            // let displayerMessage = document.createElement("li")
            // displayerMessage.innerText = '${user_name} logged in'
            // display_window.appendChild(displayerMessage)

            // let subscribeto_name = document.getElementById('subcribe-name')
            // channel.push('subscribe', {name:user_name.value, follow: subscribeto_name.value})
            // document.getElementById("myBtn-subscribe").addEventListener("click", displayLive_subscribe)

            // function displayLive_subscribe(){
            //     document.getElementById("trial_id").innerHTML = user_name.value + " has successfully subscribed to " + subscribeto_name.value
            //     }
           
            // let tweet_msg = document.getElementById('tweet-name')
            // channel.push('tweet', {name:user_name.value, tweet_msg: tweet_msg})


            
        })
        //receive events
            channel.on('register', payload => {
            
                 console.log(payload["resp"])
            })
        },

        subscribe(channel) {
            document.getElementById('add_subscriber-form').addEventListener('submit',function(e){
                e.preventDefault()
                alert("Confirm Subscription to user.")
                let user_name = document.getElementById('user-name')
                let sub_value = document.getElementById('subcribe-name')
                channel.push('subscribe', {name: user_name.value, follow: sub_value.value })
                .receive("ok", reply => {
                    console.log(reply)
                    var text = ""
                    var i;
                    for (i = 0; i < reply.tweets.length; i++) {
                        text += sub_value.value + " has tweeted " + reply.tweets[i]  + "<br>";
                    }
                    document.getElementById("tweet_subs").innerHTML =  text
                })
                document.getElementById("follow_success").innerHTML =  user_name.value + " started following " + sub_value.value
    
            })
        },
    
        tweet(channel) {
        document.getElementById('tweet-form').addEventListener('submit',function(e){
            e.preventDefault()
            alert("Publish Tweet")
            let user_name = document.getElementById('user-name')
            let tweet_value = document.getElementById('tweet-name')
            channel.push('tweet', {name: user_name.value, tweet: tweet_value.value })
            .receive("ok", reply => {
                console.log(reply)
                var text = ""
                var i;
                for (i = 0; i < reply.tweets.length; i++) {
                    text += user_name.value + " has tweeted " + reply.tweets[i]  + "<br>";
                }
                document.getElementById("tweet_div").innerHTML =  text
            })
            
            })
        },
    
        queryByHash(channel) {
        document.getElementById('query_hashtag-form').addEventListener('submit',function(e){
            e.preventDefault()
            alert("Confirm Query by Hashtag")
            let user_name = document.getElementById('user-name')
            let hash_value = document.getElementById('hashtag-name')
            channel.push('query_hashtag', {name: user_name.value, hash: hash_value.value })
            .receive("ok", reply => {
                console.log(reply)
                var text = ""
                var i;
                for (i = 0; i < reply.hashtags.length; i++) {
                    text += "Tweets by Hashtags " + hash_value.value + " are -->" + reply.hashtags[i]  + "<br>";
                }
                document.getElementById("hash_div").innerHTML =  text 
            })
            
            })
        },

            queryByMention(channel) {
            document.getElementById('query_mention-form').addEventListener('submit',function(e){
                e.preventDefault()
                alert("Confirm Query by Mention ")
                let user_name = document.getElementById('user-name')
                let mention_value = document.getElementById('mentions-name')
                channel.push('query_mentions', {name: user_name.value, mention:mention_value.value})
                .receive("ok", reply => {
                    console.log(reply)
                    var text = ""
                    var i;
                    for (i = 0; i < reply.mentions.length; i++) {
                        text += "Tweets with mention " + mention_value.value + " are -->" + reply.mentions[i]  + "<br>";
                    }
                    document.getElementById("mention_div").innerHTML =  text 
                })
                
                })
            }
}

export default TwitterEngine
