# write a shell script for macOS that uses the instagram api to check my account for what photos have been posted and then randomly select a new one to upload from a folder of photos but only if it hasn't been uploaded before
# ask for the instagram username and password
# ask for the folder of photos to upload from
# ask for the instagram account to upload to
# attempt to create a caption for the photo using openai api
# upload the photo to instagram

# get cwd
cwd=$(pwd)

# create files to store data - instagram username, password, folder of photos, instagram account to upload to, photos already uploaded, a csv file to store the file name and the caption
touch $cwd/instagram_username.txt
touch $cwd/instagram_password.txt
touch $cwd/instagram_folder.txt
touch $cwd/instagram_account.txt
touch $cwd/instagram_uploaded.txt
touch $cwd/instagram_captions.csv

# check that the csv file has a header (date, file name, caption)
if [ ! -s $cwd/instagram_captions.csv ]; then
    echo "date,filename,caption" >> $cwd/instagram_captions.csv
fi

# if the instagram username file is empty then ask for the instagram username and password
# check if the instagram username and password files are correct by showing the credentials and asking if they are correct
# if they are not correct then ask for the instagram username and password again
while [ ! -s $cwd/instagram_username.txt ] || [ ! -s $cwd/instagram_password.txt ]
do
    echo "Please enter your instagram username:"
    read instagram_username
    echo "Please enter your instagram password:"
    read instagram_password
    echo "Your instagram username is $instagram_username and your instagram password is $instagram_password"
    echo "Are these correct? (y/n)"
    read instagram_credentials_correct
    if [ $instagram_credentials_correct = "y" ]
    then
        echo $instagram_username > $cwd/instagram_username.txt
        echo $instagram_password > $cwd/instagram_password.txt
    fi
done

# if the instagram folder file is empty then ask for the folder of photos to upload from
while [ ! -s $cwd/instagram_folder.txt ]
do
    echo "Please enter the folder of photos to upload from:"
    read instagram_folder
    echo "The folder of photos to upload from is $instagram_folder"
    echo "Is this correct? (y/n)"
    read instagram_folder_correct
    if [ $instagram_folder_correct = "y" ]
    then
        echo $instagram_folder > $cwd/instagram_folder.txt
    fi
done

# change the above to allow for multiple folders of photos to upload from and then randomly select one of them - save the folder names to the instagram_folder.txt file

while [ ! -s $cwd/instagram_folder.txt ]
do
    echo "Please enter the folders of photos to upload from: (separate each folder with a return)"
    # ask for the folders of photos to upload from until the user enters a blank line
    while [ ! -z $instagram_folder ]
    do
        read instagram_folder
        if [ ! -z $instagram_folder ]
        then
            echo $instagram_folder >> $cwd/instagram_folder.txt
        fi
    done
done

# choose a random folder from the instagram_folder.txt file - macos must use $RANDOM, and make sure it exists - if it doesn't then choose another one and make sure it exists
# each folder exists on a new line in the instagram_folder.txt file
instagram_folder=$(sed -n $((RANDOM % $(wc -l < $cwd/instagram_folder.txt) + 1))p $cwd/instagram_folder.txt)
while [ ! -d $instagram_folder ]
do
    instagram_folder=$(sed -n $((RANDOM % $(wc -l < $cwd/instagram_folder.txt) + 1))p $cwd/instagram_folder.txt)
done
echo "The folder of photos to upload from is $instagram_folder"
echo "\n"

# if the instagram account file is empty then ask for the instagram account to upload to
while [ ! -s $cwd/instagram_account.txt ]
do
    echo "Please enter the instagram account to upload to:"
    read instagram_account
    echo "The instagram account to upload to is $instagram_account"
    echo "Is this correct? (y/n)"
    read instagram_account_correct
    if [ $instagram_account_correct = "y" ]
    then
        echo $instagram_account > $cwd/instagram_account.txt
    fi
done

# if the openai api key file is empty then ask for the openai api key
while [ ! -s $cwd/openai_api_key.txt ]
do
    echo "Please enter your openai api key:"
    read openai_api_key
    echo "Your openai api key is $openai_api_key"
    echo "Is this correct? (y/n)"
    read openai_api_key_correct
    if [ $openai_api_key_correct = "y" ]
    then
        echo $openai_api_key > $cwd/openai_api_key.txt
    fi
done

# get the instagram username, password, folder of photos, instagram account to upload to
instagram_username=$(cat $cwd/instagram_username.txt)
instagram_password=$(cat $cwd/instagram_password.txt)
instagram_folder=$(cat $cwd/instagram_folder.txt)
instagram_account=$(cat $cwd/instagram_account.txt)
    # echo "Your instagram username is $instagram_username and your instagram password is $instagram_password"
    # echo "The folder of photos to upload from is $instagram_folder"
    # echo "The instagram account to upload to is $instagram_account"

# get the list of photos already uploaded
instagram_uploaded=$(cat $cwd/instagram_uploaded.txt)
    # echo "The list of photos already uploaded is $instagram_uploaded"

# get the list of photos in the folder of photos to upload from (mac only)
instagram_photos=$(ls $instagram_folder)
    # echo "The list of photos in the folder of photos to upload from is $instagram_photos"

# get the list of photos in the folder of photos to upload from that have not been uploaded
instagram_photos_to_upload=$(echo "$instagram_photos" | grep -v "$instagram_uploaded")
    # echo "The list of photos in the folder of photos to upload from that have not been uploaded is $instagram_photos_to_upload"

# get the openai api key
openai_api_key=$(cat $cwd/openai_api_key.txt)
# echo "Your openai api key is $openai_api_key"

# if there are no photos to upload then exit
if [ -z "$instagram_photos_to_upload" ]
then
    echo "There are no photos to upload"
    exit
fi

# we now have a list of photos, we need to randomly select one of the photos and get the file name, mac bash only - for random we need to use $RANDOM
instagram_photo_to_upload=$(echo "$instagram_photos_to_upload" | sed -n "$((RANDOM % $(echo "$instagram_photos_to_upload" | wc -l) + 1))p")
    # echo "The photo to upload is $instagram_photo_to_upload"

# get the photo to upload file name
instagram_photo_to_upload_file_name=$(echo $instagram_photo_to_upload | cut -d '/' -f 2)
# echo "The photo to upload file name is $instagram_photo_to_upload_file_name"

# get the photo to upload file path - $instagram_folder/$instagram_photo_to_upload_file_name
instagram_photo_to_upload_file_path=$instagram_folder/$instagram_photo_to_upload_file_name
echo "The photo to upload file path is:
$instagram_photo_to_upload_file_path"
echo "\n"

# get the caption friendly name of the photo to upload - 

# repeat the above but echo the result after each step
instagram_photo_to_upload_caption_friendly_name=$(echo $instagram_photo_to_upload_file_name)

# remove the wording "DALL·E",
instagram_photo_to_upload_caption_friendly_name=$(echo $instagram_photo_to_upload_caption_friendly_name | sed 's/DALL·E //')
# echo "The photo to upload caption friendly name is:
# $instagram_photo_to_upload_caption_friendly_name"
# echo "\n"

# remove the date eg. "2021-01-01"
instagram_photo_to_upload_caption_friendly_name=$(echo $instagram_photo_to_upload_caption_friendly_name | sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} //')
# echo "The photo to upload caption friendly name is:
# $instagram_photo_to_upload_caption_friendly_name"
# echo "\n"

# remove the timestamp in the format "02.23.07 - " or "12.01.34 - " sed
instagram_photo_to_upload_caption_friendly_name=$(echo $instagram_photo_to_upload_caption_friendly_name | sed 's/[0-9][0-9].[0-9][0-9].[0-9][0-9].[-].//')
# echo "The photo to upload caption friendly name is:
# $instagram_photo_to_upload_caption_friendly_name"
# echo "\n"

# remove the ending file extension eg. ".jpg" (upto four characters)
instagram_photo_to_upload_caption_friendly_name=$(echo $instagram_photo_to_upload_caption_friendly_name | sed 's/\.[^.]*$//')
# echo "The photo to upload caption friendly name is:
# $instagram_photo_to_upload_caption_friendly_name"
# echo "\n"

# replace any double spaces with a comma and space
instagram_photo_to_upload_caption_friendly_name=$(echo $instagram_photo_to_upload_caption_friendly_name | sed 's/__/, /g')
# echo "The photo to upload caption friendly name is:
# $instagram_photo_to_upload_caption_friendly_name"
# echo "\n"

# remove the leading number if there is one
instagram_photo_to_upload_caption_friendly_name=$(echo $instagram_photo_to_upload_caption_friendly_name | sed 's/^[0-9]*_//')
# echo "The photo to upload caption friendly name is:
# $instagram_photo_to_upload_caption_friendly_name"
# echo "\n"

# replace underscores with spaces
instagram_photo_to_upload_caption_friendly_name=$(echo $instagram_photo_to_upload_caption_friendly_name | sed 's/_/ /g')
echo "The photo to upload caption friendly name is:
$instagram_photo_to_upload_caption_friendly_name"
echo "\n"

echo "Using openai api to get a captions for the photo..."
echo "\n"

# write a caption function using the above caption code
write_caption() {
    # use openai api to get a caption for the photo
    # use the photo to upload file name as the prompt
    # the prompt should be something like "create an instagram caption for the photo with the file name <instagram_photo_to_upload_file_name> and the caption should contain popular hashtags that are relevant to the photo, include a maximum of 20 hashtags"
    # max_tokens=100
    # temperature=1
    # omit the stop parameter so that the api will generate the full caption

    # caption=$(curl -s -H "Authorization: Bearer $openai_api_key" -H "Content-Type: application/json" -d '{"prompt": "write a caption for an instagram post named: '"$instagram_photo_to_upload_caption_friendly_name"', write a list of popular instagram hashtags # that are relevant to the post:", "max_tokens": 80, "best_of": 10, "temperature": 1}' https://api.openai.com/v1/engines/davinci/completions )
    caption=$(curl -s -H "Authorization: Bearer $openai_api_key" -H "Content-Type: application/json" -d '{"prompt": "write a list of instagram hashtags for a post titled: '"$instagram_photo_to_upload_caption_friendly_name"': #art", "max_tokens": 80, "best_of": 1, "temperature": 1}' https://api.openai.com/v1/engines/davinci/completions )
    # echo "The caption is $caption"

    # get the caption from the json response
    # parse error: Invalid string: control characters from U+0000 through U+001F must be escaped at line 9, column 6
    # filter out the control characters from the json response
    # Make sure the print utility you are using does not interpret newlines: printf "%s
    caption=$(printf "%s" "$caption" | jq -r '.choices[0].text')
    echo "\n
$caption"
    echo "\n"

# write each caption to the instagram captions csv file with the date and time and file path. strip out any commas or new lines from the caption
caption_1=$(echo $caption | cut -d ',' -f 1)
echo "$(date), $instagram_photo_to_upload_file_path, $caption_1" >> $cwd/instagram_captions.csv
}

# output 5 captions
for i in {1..5}
do
    echo "Caption $i:"
    write_caption
done
# upload the photo to instagram with the caption
