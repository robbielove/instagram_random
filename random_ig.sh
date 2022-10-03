# write a shell script for macOS that uses the instagram api to check my account for what photos have been posted and then randomly select a new one to upload from a folder of photos but only if it hasn't been uploaded before
# ask for the instagram username and password
# ask for the folder of photos to upload from
# ask for the instagram account to upload to
# attempt to create a caption for the photo using openai api
# upload the photo to instagram

# get cwd
cwd=$(pwd)

# create files to store data - instagram folder of photos, photos already uploaded, a csv file to store the date, file name and the caption
touch $cwd/instagram_folder.txt
touch $cwd/instagram_uploaded.txt
touch $cwd/instagram_captions.csv

# check that the csv file has a header (date, filename, caption)
if [ ! -s $cwd/instagram_captions.csv ]; then
    echo "date,filename,caption" >> $cwd/instagram_captions.csv
fi

# if the instagram folder file is empty then ask for of folders of photos to upload from and then randomly select one of the folders - save the folder names to the instagram_folder.txt file, save the chosen folder to the variable instagram_folder
while [ ! -s $cwd/instagram_folder.txt ]
do
    echo "Please enter the folders of photos to upload from (press enter after each folder):"
    # read the folders of photos to upload from until the user presses enter without entering a folder name
    while read -r instagram_folders
    do
        if [ -z "$instagram_folders" ]
        then
            break
        fi
        echo $instagram_folders >> $cwd/instagram_folder.txt
    done
done


# create a function that gets all the files in the folders of photos to upload from and then randomly selects one of the files - checking the file instagram_uploaded.txt first and if found; repeating unitl a file is chosen, it then adds the full path to the file to the $instagram_photo_to_upload_file_name variable
function get_random_photo_to_upload {
    # get the number of folders of photos to upload from
    instagram_folders=$(cat $cwd/instagram_folder.txt | wc -l)
    # get a random number between 1 and the number of folders of photos to upload from
    instagram_folder_number=$(( ( RANDOM % $instagram_folders )  + 1 ))
    # get the folder name of the folder of photos to upload from
    instagram_folder=$(sed -n "$instagram_folder_number p" $cwd/instagram_folder.txt)
    # get the number of files in the folder of photos to upload from
    instagram_photos=$(ls $instagram_folder | wc -l)
    # get a random number between 1 and the number of files in the folder of photos to upload from
    instagram_photo_number=$(( ( RANDOM % $instagram_photos )  + 1 ))
    # get the file name of the photo to upload
    instagram_photo_to_upload=$(ls $instagram_folder | sed -n "$instagram_photo_number p")
    # get the full path and the file name of the photo to upload
    instagram_photo_to_upload_file_path=$instagram_folder/$instagram_photo_to_upload
    instagram_photo_to_upload_file_name=$instagram_photo_to_upload
    # check if the photo has already been uploaded
    if grep -Fxq "$instagram_photo_to_upload_file_name" $cwd/instagram_uploaded.txt
    then
        # if the photo has already been uploaded then run the function again
        get_random_photo_to_upload
    fi
}

# run the function to get the file name of the photo to upload
get_random_photo_to_upload

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

# get the caption friendly name of the photo to upload
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

# echo the file path is:
echo "The file path is:
$instagram_photo_to_upload_file_path"
echo "\n"

# open the file selected in finder
open --reveal $instagram_photo_to_upload_file_path

# replace underscores with spaces
instagram_photo_to_upload_caption_friendly_name=$(echo $instagram_photo_to_upload_caption_friendly_name | sed 's/_/ /g')
echo "The photo to upload caption friendly name is:
$instagram_photo_to_upload_caption_friendly_name"
echo "\n"

# ask the user if they want to upload the photo
echo "Do you want to upload the photo? (y/n)"
read upload_photo

# if the user wants to upload the photo then record the photo as uploaded and continue getting the caption otherwise exit
if [ $upload_photo = "y" ]
then
    echo $instagram_photo_to_upload_file_name >> $cwd/instagram_uploaded.txt
else
    exit
fi

echo "Using openai api to get a captions for the photo..."
echo "\n"

# write a caption function using the above caption code
write_caption() {
    # use openai api to get a caption for the photo
    # get the openai api key from the file openai_api_key.txt
    openai_api_key=$(cat $cwd/openai_api_key.txt)
    # use the photo to upload file name as the prompt
    # the prompt should be something like "create an instagram caption for the photo with the file name <instagram_photo_to_upload_file_name> and the caption should contain popular hashtags that are relevant to the photo, include a maximum of 20 hashtags"
    # max_tokens=100
    # temperature=1
    # omit the stop parameter so that the api will generate the full caption

    # caption=$(curl -s -H "Authorization: Bearer $openai_api_key" -H "Content-Type: application/json" -d '{"prompt": "write a caption for an instagram post named: '"$instagram_photo_to_upload_caption_friendly_name"', write a list of popular instagram hashtags # that are relevant to the post:", "max_tokens": 80, "best_of": 10, "temperature": 1}' https://api.openai.com/v1/engines/davinci/completions )
    caption=$(curl -s -H "Authorization: Bearer $openai_api_key" -H "Content-Type: application/json" -d '{"prompt": "write a list of instagram hashtags for a post titled: '"$instagram_photo_to_upload_caption_friendly_name"': #", "max_tokens": 80, "best_of": 1, "temperature": 1}' https://api.openai.com/v1/engines/davinci/completions )
    # echo "The caption is $caption"

    # get the caption from the json response
    # parse error: Invalid string: control characters from U+0000 through U+001F must be escaped at line 9, column 6
    # filter out the control characters from the json response
    # Make sure the print utility you are using does not interpret newlines: printf "%s
    caption=$(printf "%s" "$caption" | jq -r '.choices[0].text')
    caption=$(echo $caption | cut -d ',' -f 1)
    echo "\n
$caption"
    echo "\n"

    # write each caption to the instagram captions csv file with the date and time and file path. strip out any commas or new lines from the caption
    echo "$(date), $instagram_photo_to_upload_file_path, $caption" >> $cwd/instagram_captions.csv
}

# output 5 captions
for i in {1..5}
do
    echo "Caption $i:"
    write_caption
done