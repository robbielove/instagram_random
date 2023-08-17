#!/bin/bash

DIR_ARG="$1"

cwd=$(pwd)
instagram_folder_file="$cwd/instagram_folder.txt"
uploaded_photos_file="$cwd/instagram_uploaded.txt"
openai_key_file="$cwd/openai_api_key.txt"

touch $instagram_folder_file $uploaded_photos_file

openai_api_key=$(cat $openai_key_file)

get_random_photo() {
  local folder photos photo
  local -i index=0

  if [ "$DIR_ARG" != "" ]; then
    folder="$DIR_ARG"
  else
    folder=$(cat $instagram_folder_file)
  fi

  while IFS= read -r -d $'\0' file; do
    photos[index++]="$file"
  done < <(find "$folder" -type f -print0)

  photo="${photos[$RANDOM % ${#photos[@]}]}"

  if ! grep -q "$photo" $uploaded_photos_file; then
    echo "$photo"
    return
  fi
}

prompt_for_hashtags() {
  local photo_name response caption curl_command

  photo_name=$(basename "$1")
  curl_command="curl -s -H 'Authorization: Bearer $openai_api_key' -H 'Content-Type: application/json' -d '{\"model\": \"gpt-3.5-turbo\", \"max_tokens\": 120, \"temperature\": 1, 
   \"messages\": [{\"role\": \"system\", \"content\": \"You are an Instagram hashtag generator. Provide detailed and bulk relevant hashtags based on the given filename, make the hashtags for instagram.\"}, {\"role\": \"user\", \"content\": \"Photo title: $photo_name.\"}]}' https://api.openai.com/v1/chat/completions"

  echo "Prompting OpenAI API for hashtags..." >&2
  echo "Executing: $curl_command" >&2
  response=$(eval $curl_command)

  # Check if response has content
  if [ -z "$response" ]; then
    echo "Received empty response from API." >&2
    read -p "Press any key to continue..."
    return 1
  fi

  echo "API response: $response" >&2

  # Error handling for API call
  if echo "$response" | grep -q "error"; then
    error_message=$(echo $response | jq -r '.error.message')
    echo "API Error: $error_message"
    read -p "Press any key to continue..."
    return 1
  fi

  caption=$(echo $response | jq -r '.choices[0].message.content')
  echo "$caption"
}

while true; do
  photo_path=$(get_random_photo)
  echo "Selected photo: $photo_path"

  open "$photo_path"
  echo "What would you like to do with this photo?"
  echo "(U) Upload this photo"
  echo "(R) Retry with another"
  echo "(X) Exit"
  read -p "Choose: " choice

  if [ "$choice" == "u" ] || [ "$choice" == "U" ]; then
    hashtags=$(prompt_for_hashtags "$photo_path")
    if [ $? -eq 1 ]; then
      continue
    fi
    echo "Suggested hashtags: $hashtags"
    read -p "Use these hashtags? (Y/N) " choice

    if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
      basename "$photo_path" >> $uploaded_photos_file
      echo "Uploading photo with hashtags: $hashtags"
    fi
  elif [ "$choice" == "r" ] || [ "$choice" == "R" ]; then
    continue
  elif [ "$choice" == "x" ] || [ "$choice" == "X" ]; then
    break
  fi
done
