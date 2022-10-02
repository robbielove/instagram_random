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

# make sure the folder of photos to upload from exists
while [ ! -d $instagram_folder ]
do
    echo "The folder of photos to upload from does not exist"
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
echo "The photo to upload file path is $instagram_photo_to_upload_file_path"

# get the caption friendly name of the photo to upload - remove the file extension and replace underscores with spaces and remove the leading number
instagram_photo_to_upload_caption_friendly_name=$(echo $instagram_photo_to_upload_file_name | cut -d '.' -f 1 | sed 's/_/ /g' | sed 's/^[0-9]*//')
echo "The caption friendly name of the photo to upload is $instagram_photo_to_upload_caption_friendly_name"

# use openai api to get a caption for the photo
# use the photo to upload file name as the prompt
# the prompt should be something like "create an instagram caption for the photo with the file name <instagram_photo_to_upload_file_name> and the caption should contain popular hashtags that are relevant to the photo, include a maximum of 20 hashtags"
# max_tokens=100
# temperature=1
# omit the stop parameter so that the api will generate the full caption
echo "Using openai api to get a caption for the photo"
# caption=$(curl -s -H "Authorization: Bearer $openai_api_key" -H "Content-Type: application/json" -d '{"prompt": "write a caption for an instagram post named: '"$instagram_photo_to_upload_caption_friendly_name"', write a list of popular instagram hashtags # that are relevant to the post:", "max_tokens": 80, "best_of": 10, "temperature": 1}' https://api.openai.com/v1/engines/davinci/completions )
caption=$(curl -s -H "Authorization: Bearer $openai_api_key" -H "Content-Type: application/json" -d '{"prompt": "write instagram post named: '"$instagram_photo_to_upload_caption_friendly_name"', write a list instagram hashtags:", "max_tokens": 80, "best_of": 1, "temperature": 1}' https://api.openai.com/v1/engines/davinci/completions )
# echo "The caption is $caption"

# get the caption from the json response
# parse error: Invalid string: control characters from U+0000 through U+001F must be escaped at line 9, column 6
# filter out the control characters from the json response
# Make sure the print utility you are using does not interpret newlines: printf "%s
caption=$(printf "%s" "$caption" | jq -r '.choices[0].text')
echo "The caption is $caption"
# write the caption to the instagram captions csv file with the date and time and file path. add quotes around the caption text incase it contains a comma
echo "$(date), $instagram_photo_to_upload_file_path, '$caption'" >> $cwd/instagram_captions.csv
# upload the photo to instagram with the caption
