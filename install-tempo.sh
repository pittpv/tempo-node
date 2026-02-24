#!/usr/bin/env bash
#
# Tempo Node Installer вЂ” Moderato (Testnet)
# Docker image ghcr.io/tempoxyz/tempo:1.1.4
# RPC: https://docs.tempo.xyz/guide/node/rpc | Validator: https://docs.tempo.xyz/guide/node/validator
# Snapshots: https://docs.tempo.xyz/guide/node/rpc#manually-downloading-snapshots
# Guide: https://github.com/mztacat/Setting-up-Tempo-Node
#
# NOTE: if you make modifications to this script, please increment the version number.
# WARNING: the SemVer pattern: major.minor.patch must be followed as we use it to determine if the script is up to date.
INSTALLER_VERSION="2.1.0"

set -euo pipefail

# Set UTF-8 encoding for proper display of non-ASCII characters
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# === Language settings ===
LANG="en"
declare -A TRANSLATIONS

t() {
  local key=$1
  echo "${TRANSLATIONS["${LANG},${key}"]:-$key}"
}

init_languages() {
  echo -e "\n${BLUE}Select language / Выберите язык:${NC}"
  echo "1. English"
  echo "2. Русский"
  echo "3. Türkçe"
  read -e -p "> " lang_choice
  case $lang_choice in
    2) LANG="ru" ;;
    3) LANG="tr" ;;
    *) LANG="en" ;;
  esac

  # English
  TRANSLATIONS["en,title"]="========= Tempo Node (Moderato) ========="
  TRANSLATIONS["en,option1"]="1. Install Tempo RPC Node (Docker)"
  TRANSLATIONS["en,option1b"]="2. Install Tempo Validator Node (Docker)"
  TRANSLATIONS["en,option_snap"]="3. Snapshot: download / choose version and restart node"
  TRANSLATIONS["en,option2"]="4. Downgrade node version"
  TRANSLATIONS["en,option3"]="5. Node version"
  TRANSLATIONS["en,option4"]="6. View node logs"
  TRANSLATIONS["en,option0"]="0. Exit"
  TRANSLATIONS["en,choose_option"]="Select option:"
  TRANSLATIONS["en,invalid_choice"]="Invalid choice. Try again."
  TRANSLATIONS["en,goodbye"]="Goodbye."
  TRANSLATIONS["en,checking_docker"]="Checking Docker..."
  TRANSLATIONS["en,docker_not_found"]="Docker not installed."
  TRANSLATIONS["en,docker_required"]="Docker is required. Exiting."
  TRANSLATIONS["en,docker_found"]="Docker found."
  TRANSLATIONS["en,checking_ports"]="Checking ports..."
  TRANSLATIONS["en,port_busy"]="Port is in use."
  TRANSLATIONS["en,port_free"]="Port is free."
  TRANSLATIONS["en,enter_fee_recipient"]="Enter FEE_RECIPIENT (EVM address for rewards, with 0x): "
  TRANSLATIONS["en,fee_recipient_required"]="FEE_RECIPIENT is required. Exiting."
  TRANSLATIONS["en,creating_dirs"]="Creating data and key directories..."
  TRANSLATIONS["en,generating_key"]="Generating consensus signing key..."
  TRANSLATIONS["en,key_exists"]="Signing key already exists, skipping."
  TRANSLATIONS["en,downloading_snapshot"]="Downloading chain snapshot (this may take a while)..."
  TRANSLATIONS["en,snapshot_retry"]="Snapshot download failed (attempt %s/%s). Retrying in 15s..."
  TRANSLATIONS["en,snapshot_failed"]="Snapshot download failed after %s attempts. Check your network and try again."
  TRANSLATIONS["en,pulling_image"]="Pulling Docker image..."
  TRANSLATIONS["en,creating_compose"]="Creating docker-compose.yml..."
  TRANSLATIONS["en,starting_node"]="Starting Tempo node..."
  TRANSLATIONS["en,install_done"]="Installation complete."
  TRANSLATIONS["en,rpc_info"]="RPC: http://%s:%s (local)"
  TRANSLATIONS["en,p2p_info"]="P2P: tcp/udp %s"
  TRANSLATIONS["en,node_not_installed"]="Tempo node not installed (no docker-compose in %s)"
  TRANSLATIONS["en,downgrade_title"]="Downgrade Tempo node"
  TRANSLATIONS["en,downgrade_fetching"]="Fetching available versions..."
  TRANSLATIONS["en,downgrade_available"]="Available versions (enter number):"
  TRANSLATIONS["en,downgrade_show_all"]="Show all versions (X.Y.Z only)"
  TRANSLATIONS["en,downgrade_invalid_choice"]="Invalid choice."
  TRANSLATIONS["en,downgrade_selected"]="Selected version:"
  TRANSLATIONS["en,downgrade_fetch_error"]="Could not fetch version list. Choose from list or enter custom tag."
  TRANSLATIONS["en,downgrade_folder_error"]="Folder %s not found."
  TRANSLATIONS["en,downgrade_pulling"]="Pulling image"
  TRANSLATIONS["en,downgrade_pull_error"]="Failed to pull image."
  TRANSLATIONS["en,downgrade_stopping"]="Stopping containers..."
  TRANSLATIONS["en,downgrade_removing_data"]="Removing chain data..."
  TRANSLATIONS["en,downgrade_downloading_snapshot"]="Re-downloading snapshot for chain %s..."
  TRANSLATIONS["en,downgrade_updating"]="Updating docker-compose..."
  TRANSLATIONS["en,downgrade_starting"]="Starting node"
  TRANSLATIONS["en,downgrade_success"]="Node downgraded to version"
  TRANSLATIONS["en,version_title"]="Tempo node version"
  TRANSLATIONS["en,container_not_found"]="Tempo container not found."
  TRANSLATIONS["en,container_found"]="Container:"
  TRANSLATIONS["en,node_version"]="Tempo node version:"
  TRANSLATIONS["en,version_failed"]="Could not get version."
  TRANSLATIONS["en,view_logs"]="View Tempo logs"
  TRANSLATIONS["en,press_ctrlc"]="Press Ctrl+C to exit logs."
  TRANSLATIONS["en,return_menu"]="Returning to menu..."
  TRANSLATIONS["en,option6"]="7. Remove node"
  TRANSLATIONS["en,remove_title"]="Remove Tempo node"
  TRANSLATIONS["en,remove_not_installed"]="Tempo node not installed (no docker-compose in %s)"
  TRANSLATIONS["en,remove_confirm_full"]="Full removal: stop container and delete data, keys, and config. Type 'yes' to confirm: "
  TRANSLATIONS["en,remove_confirm_container"]="Remove only container (data and keys will be kept). Type 'yes' to confirm: "
  TRANSLATIONS["en,remove_cancelled"]="Returning to main menu."
  TRANSLATIONS["en,remove_stopping"]="Stopping and removing container..."
  TRANSLATIONS["en,remove_deleting"]="Deleting data, keys, and config..."
  TRANSLATIONS["en,remove_done"]="Node removed."
  TRANSLATIONS["en,remove_done_kept"]="Container removed. Data and keys kept in %s"
  TRANSLATIONS["en,remove_option_container"]="1) Remove container only (keep data and keys)"
  TRANSLATIONS["en,remove_option_full"]="2) Full removal (delete data, keys, config)"
  TRANSLATIONS["en,remove_choose"]="1 or 2: "
  TRANSLATIONS["en,update_installer_title"]="Update installer script"
  TRANSLATIONS["en,update_installer_no_url"]="SCRIPT_URL not set. Cannot update installer."
  TRANSLATIONS["en,update_installer_downloading"]="Downloading latest installer..."
  TRANSLATIONS["en,update_installer_failed"]="Failed to download installer update"
  TRANSLATIONS["en,update_installer_no_version"]="Failed to determine remote version"
  TRANSLATIONS["en,update_installer_up_to_date"]="Installer is already up to date (version %s)"
  TRANSLATIONS["en,update_installer_updating"]="Updating from %s to %s..."
  TRANSLATIONS["en,update_installer_failed_copy"]="Failed to update installer. Try running with sudo."
  TRANSLATIONS["en,update_installer_success"]="вњ“ Installer updated successfully to version %s"
  TRANSLATIONS["en,installer_version"]="Installer version: %s"
  TRANSLATIONS["en,option8"]="8. Check for updates"
  TRANSLATIONS["en,snapshot_title"]="Snapshot: choose version, download, restart node"
  TRANSLATIONS["en,snapshot_list"]="Available snapshots for chain %s (chainId %s):"
  TRANSLATIONS["en,snapshot_latest"]="Use latest snapshot (recommended)"
  TRANSLATIONS["en,snapshot_enter_url"]="Enter snapshot URL manually"
  TRANSLATIONS["en,snapshot_extract_local"]="Extract from local file (.tar.lz4 path)"
  TRANSLATIONS["en,snapshot_choice"]="Choice (number, 0=latest, u=URL, e=local file): "
  TRANSLATIONS["en,lz4_no_threading"]="Your lz4 does not support multi-threading (-T)."
  TRANSLATIONS["en,lz4_update_ask"]="Update lz4 from source (build with -T support)? (y/n): "
  TRANSLATIONS["en,snapshot_downloading"]="Downloading snapshot..."
  TRANSLATIONS["en,snapshot_done"]="Snapshot downloaded successfully."
  TRANSLATIONS["en,snapshot_restart_ask"]="Restart node now? (y/n): "
  TRANSLATIONS["en,snapshot_restarting"]="Restarting node..."
  TRANSLATIONS["en,snapshot_no_compose"]="Node not installed (no docker-compose). Install RPC or Validator first."
  TRANSLATIONS["en,rpc_node_info"]="RPC Node: syncs chain, serves API; no validator key needed."
  TRANSLATIONS["en,validator_node_info"]="Validator Node: produces blocks, needs whitelist and signing key."
  TRANSLATIONS["en,check_updates_title"]="Check for updates"
  TRANSLATIONS["en,check_updates_latest"]="Latest Tempo version: %s"
  TRANSLATIONS["en,check_updates_current"]="Current installed version: %s"
  TRANSLATIONS["en,check_updates_newer"]="A newer version is available!"
  TRANSLATIONS["en,check_updates_current_latest"]="You are running the latest version."
  TRANSLATIONS["en,option_stop"]="9. Stop container"
  TRANSLATIONS["en,option_start"]="10. Start container"
  TRANSLATIONS["en,option_check_sync"]="11. Check sync (peers, block height)"
  TRANSLATIONS["en,option_disk"]="12. Check disk usage"
  TRANSLATIONS["en,disk_usage"]="Disk space usage"
  TRANSLATIONS["en,disk_usage_data"]="Tempo (%s) — data:"
  TRANSLATIONS["en,disk_usage_keys"]="Tempo (%s) — keys:"
  TRANSLATIONS["en,disk_usage_container_off"]="Container not running; showing host path size:"
  TRANSLATIONS["en,select_node_which"]="Which node?"
  TRANSLATIONS["en,select_node_rpc"]="1) RPC (%s/rpc)"
  TRANSLATIONS["en,select_node_validator"]="2) Validator (%s/validator)"
  TRANSLATIONS["en,select_node_cancel"]="0) Return to main menu"
  TRANSLATIONS["en,status_running"]="running"
  TRANSLATIONS["en,status_stopped"]="stopped"
  TRANSLATIONS["en,node_not_installed_any"]="No Tempo node installed (no docker-compose in %s or subdirs)."
  TRANSLATIONS["en,stop_done"]="Container stopped."
  TRANSLATIONS["en,start_done"]="Container started."
  TRANSLATIONS["en,check_sync_title"]="Check sync and blocks (RPC: %s)"
  TRANSLATIONS["en,check_sync_peers"]="Peer count (should be non-zero):"
  TRANSLATIONS["en,check_sync_block_height"]="Block height (should be steadily increasing):"
  TRANSLATIONS["en,check_sync_block_info"]="Latest block:"
  TRANSLATIONS["en,check_sync_no_compose"]="Node not installed (no docker-compose)."
  TRANSLATIONS["en,check_sync_cast_required"]="Install Foundry (cast) for RPC checks: https://getfoundry.sh"
  TRANSLATIONS["en,check_sync_rpc_failed"]="RPC request failed. Is the node running and reachable at %s?"
  TRANSLATIONS["en,check_sync_menu_title"]="Check sync and blocks (RPC: %s)"
  TRANSLATIONS["en,check_sync_sub_peers"]="1. Peer count (should be non-zero)"
  TRANSLATIONS["en,check_sync_sub_block_number"]="2. Block height (should be steadily increasing)"
  TRANSLATIONS["en,check_sync_sub_block"]="3. Latest block info"
  TRANSLATIONS["en,check_sync_sub_sync_status"]="4. Sync status (eth_syncing, Reth stages)"
  TRANSLATIONS["en,check_sync_back"]="0) Return to main menu"
  TRANSLATIONS["en,sync_status_title"]="Sync status (eth_syncing)"
  TRANSLATIONS["en,sync_status_synced"]="Node is fully synced (eth_syncing = false)."
  TRANSLATIONS["en,sync_status_syncing"]="Node is syncing (Reth)."
  TRANSLATIONS["en,sync_status_blocks"]="Blocks: start %s, current %s, highest %s"
  TRANSLATIONS["en,sync_status_progress"]="Progress: %s%%"
  TRANSLATIONS["en,sync_status_network"]="Network (Moderato RPC): block %s"
  TRANSLATIONS["en,sync_status_lag"]="Lag behind network: %s blocks"
  TRANSLATIONS["en,sync_status_stages"]="Reth stages (stage → block):"
  TRANSLATIONS["en,sync_status_warp"]="Warp: %s / %s chunks"
  TRANSLATIONS["en,sync_status_rpc_failed"]="RPC request failed. Is the node running?"
  TRANSLATIONS["en,checking_deps"]="Checking required dependencies..."
  TRANSLATIONS["en,missing_tools"]="Missing:"
  TRANSLATIONS["en,install_prompt"]="Install missing dependencies now? (Y/n): "
  TRANSLATIONS["en,installed"]="installed"
  TRANSLATIONS["en,not_installed"]="not installed"
  TRANSLATIONS["en,missing_required"]="Required dependencies are missing. Exiting."
  TRANSLATIONS["en,installing_docker"]="Installing Docker..."
  TRANSLATIONS["en,installing_compose"]="Installing Docker Compose..."
  TRANSLATIONS["en,install_docker_prompt"]="Install Docker? (y/n) "
  TRANSLATIONS["en,install_compose_prompt"]="Install Docker Compose? (y/n) "
  TRANSLATIONS["en,compose_required"]="Docker Compose is required. Exiting."
  TRANSLATIONS["en,docker_installed"]="Docker installed."
  TRANSLATIONS["en,compose_installed"]="Docker Compose installed."
  TRANSLATIONS["en,installing_curl"]="Installing curl..."
  TRANSLATIONS["en,installing_jq"]="Installing jq..."
  TRANSLATIONS["en,installing_lz4"]="Installing lz4..."
  TRANSLATIONS["en,installing_utils"]="Installing grep/sed..."
  TRANSLATIONS["en,installing_wget"]="Installing wget..."
  TRANSLATIONS["en,installing_tar"]="Installing tar..."
  TRANSLATIONS["en,installing_git"]="Installing git..."
  TRANSLATIONS["en,installing_make"]="Installing make..."
  TRANSLATIONS["en,installing_pv"]="Installing pv..."
  TRANSLATIONS["en,installing_rsync"]="Installing rsync..."

  # Russian (based on English phrases)
  TRANSLATIONS["ru,title"]="========= Нода Tempo (Moderato) ========="
  TRANSLATIONS["ru,option1"]="1. Установить Tempo RPC Node (Docker)"
  TRANSLATIONS["ru,option1b"]="2. Установить Tempo Validator Node (Docker)"
  TRANSLATIONS["ru,option_snap"]="3. Снепшот: загрузка / выбор версии и перезапуск ноды"
  TRANSLATIONS["ru,option2"]="4. Понизить версию ноды"
  TRANSLATIONS["ru,option3"]="5. Версия ноды"
  TRANSLATIONS["ru,option4"]="6. Просмотр логов"
  TRANSLATIONS["ru,option0"]="0. Выход"
  TRANSLATIONS["ru,choose_option"]="Введите пункт меню:"
  TRANSLATIONS["ru,invalid_choice"]="Неверный выбор."
  TRANSLATIONS["ru,goodbye"]="До свидания."
  TRANSLATIONS["ru,checking_docker"]="Проверка Docker..."
  TRANSLATIONS["ru,docker_not_found"]="Docker не установлен."
  TRANSLATIONS["ru,docker_required"]="Требуется Docker. Выход."
  TRANSLATIONS["ru,docker_found"]="Docker найден."
  TRANSLATIONS["ru,checking_ports"]="Проверка портов..."
  TRANSLATIONS["ru,port_busy"]="Порт занят."
  TRANSLATIONS["ru,port_free"]="Порт свободен."
  TRANSLATIONS["ru,enter_fee_recipient"]="Введите FEE_RECIPIENT (EVM-адрес для наград, с 0x): "
  TRANSLATIONS["ru,fee_recipient_required"]="FEE_RECIPIENT обязателен. Выход."
  TRANSLATIONS["ru,creating_dirs"]="Создание каталогов данных и ключей..."
  TRANSLATIONS["ru,generating_key"]="Генерация ключа консенсуса..."
  TRANSLATIONS["ru,key_exists"]="Ключ подписи уже есть, пропуск."
  TRANSLATIONS["ru,downloading_snapshot"]="Загрузка снепшота цепи (может занять время)..."
  TRANSLATIONS["ru,snapshot_retry"]="Ошибка загрузки снапшота (попытка %s/%s). Повтор через 15 с..."
  TRANSLATIONS["ru,snapshot_failed"]="Загрузка снапшота не удалась после %s попыток. Проверьте сеть и запустите снова."
  TRANSLATIONS["ru,pulling_image"]="Загрузка Docker-образа..."
  TRANSLATIONS["ru,creating_compose"]="Создание docker-compose.yml..."
  TRANSLATIONS["ru,starting_node"]="Запуск ноды Tempo..."
  TRANSLATIONS["ru,install_done"]="Установка завершена."
  TRANSLATIONS["ru,rpc_info"]="RPC: http://%s:%s (локально)"
  TRANSLATIONS["ru,p2p_info"]="P2P: tcp/udp %s"
  TRANSLATIONS["ru,node_not_installed"]="Нода Tempo не установлена (нет docker-compose в %s)"
  TRANSLATIONS["ru,downgrade_title"]="Понижение версии ноды Tempo"
  TRANSLATIONS["ru,downgrade_fetching"]="Получение списка версий..."
  TRANSLATIONS["ru,downgrade_available"]="Доступные версии (введите номер):"
  TRANSLATIONS["ru,downgrade_show_all"]="Показать все версии (только X.Y.Z)"
  TRANSLATIONS["ru,downgrade_invalid_choice"]="Неверный выбор."
  TRANSLATIONS["ru,downgrade_selected"]="Выбрана версия:"
  TRANSLATIONS["ru,downgrade_fetch_error"]="Не удалось получить список версий. Выберите из списка или введите тег вручную."
  TRANSLATIONS["ru,downgrade_folder_error"]="Каталог %s не найден."
  TRANSLATIONS["ru,downgrade_pulling"]="Загрузка образа"
  TRANSLATIONS["ru,downgrade_pull_error"]="Ошибка загрузки образа."
  TRANSLATIONS["ru,downgrade_stopping"]="Остановка контейнеров..."
  TRANSLATIONS["ru,downgrade_removing_data"]="Удаление данных цепи..."
  TRANSLATIONS["ru,downgrade_downloading_snapshot"]="Повторная загрузка снапшота для сети %s..."
  TRANSLATIONS["ru,downgrade_updating"]="Обновление docker-compose..."
  TRANSLATIONS["ru,downgrade_starting"]="Запуск ноды"
  TRANSLATIONS["ru,downgrade_success"]="Нода понижена до версии"
  TRANSLATIONS["ru,version_title"]="Версия ноды Tempo"
  TRANSLATIONS["ru,container_not_found"]="Контейнер Tempo не найден."
  TRANSLATIONS["ru,container_found"]="Контейнер:"
  TRANSLATIONS["ru,node_version"]="Версия ноды Tempo:"
  TRANSLATIONS["ru,version_failed"]="Не удалось получить версию."
  TRANSLATIONS["ru,view_logs"]="Просмотр логов Tempo"
  TRANSLATIONS["ru,press_ctrlc"]="Нажмите Ctrl+C для выхода из логов."
  TRANSLATIONS["ru,return_menu"]="Возврат в меню..."
  TRANSLATIONS["ru,option6"]="7. Удалить ноду"
  TRANSLATIONS["ru,remove_title"]="Удаление ноды Tempo"
  TRANSLATIONS["ru,remove_not_installed"]="Нода Tempo не установлена (нет docker-compose в %s)"
  TRANSLATIONS["ru,remove_confirm_full"]="Полное удаление: остановить контейнер и удалить данные, ключи и конфиг. Введите 'yes' для подтверждения: "
  TRANSLATIONS["ru,remove_confirm_container"]="Удалить только контейнер (данные и ключи сохранятся). Введите 'yes' для подтверждения: "
  TRANSLATIONS["ru,remove_cancelled"]="Возврат в основное меню."
  TRANSLATIONS["ru,remove_stopping"]="Остановка и удаление контейнера..."
  TRANSLATIONS["ru,remove_deleting"]="Удаление данных, ключей и конфига..."
  TRANSLATIONS["ru,remove_done"]="Нода удалена."
  TRANSLATIONS["ru,remove_done_kept"]="Контейнер удалён. Данные и ключи сохранены в %s"
  TRANSLATIONS["ru,remove_option_container"]="1) Удалить только контейнер (данные и ключи сохранить)"
  TRANSLATIONS["ru,remove_option_full"]="2) Полное удаление (данные, ключи, конфиг)"
  TRANSLATIONS["ru,remove_choose"]="1 или 2: "
  TRANSLATIONS["ru,update_installer_title"]="Обновление скрипта установщика"
  TRANSLATIONS["ru,update_installer_no_url"]="SCRIPT_URL не установлен. Невозможно обновить установщик."
  TRANSLATIONS["ru,update_installer_downloading"]="Загрузка последней версии установщика..."
  TRANSLATIONS["ru,update_installer_failed"]="Не удалось загрузить обновление установщика"
  TRANSLATIONS["ru,update_installer_no_version"]="Не удалось определить удалённую версию"
  TRANSLATIONS["ru,update_installer_up_to_date"]="Установщик уже актуален (версия %s)"
  TRANSLATIONS["ru,update_installer_updating"]="Обновление с %s до %s..."
  TRANSLATIONS["ru,update_installer_failed_copy"]="Не удалось обновить установщик. Попробуйте запустить с sudo."
  TRANSLATIONS["ru,update_installer_success"]="✓ Установщик успешно обновлён до версии %s"
  TRANSLATIONS["ru,installer_version"]="Версия установщика: %s"
  TRANSLATIONS["ru,option8"]="8. Проверить обновления"
  TRANSLATIONS["ru,snapshot_title"]="Снепшот: выбор версии, загрузка, перезапуск ноды"
  TRANSLATIONS["ru,snapshot_list"]="Доступные снепшоты для сети %s (chainId %s):"
  TRANSLATIONS["ru,snapshot_latest"]="Использовать последний снепшот (рекомендуется)"
  TRANSLATIONS["ru,snapshot_enter_url"]="Ввести URL снепшота вручную"
  TRANSLATIONS["ru,snapshot_extract_local"]="Распаковать из локального файла (путь к .tar.lz4)"
  TRANSLATIONS["ru,snapshot_choice"]="Выбор (номер, 0=последний, u=URL, e=лок. файл): "
  TRANSLATIONS["ru,lz4_no_threading"]="Ваш lz4 не поддерживает многопоточность (-T)."
  TRANSLATIONS["ru,lz4_update_ask"]="Обновить lz4 из исходников (сборка с поддержкой -T)? (y/n): "
  TRANSLATIONS["ru,snapshot_downloading"]="Загрузка снепшота..."
  TRANSLATIONS["ru,snapshot_done"]="Снепшот успешно загружен."
  TRANSLATIONS["ru,snapshot_restart_ask"]="Перезапустить ноду сейчас? (y/n): "
  TRANSLATIONS["ru,snapshot_restarting"]="Перезапуск ноды..."
  TRANSLATIONS["ru,snapshot_no_compose"]="Нода не установлена (нет docker-compose). Сначала установите RPC или Validator."
  TRANSLATIONS["ru,rpc_node_info"]="RPC Node: синхронизация цепи, API; ключ валидатора не нужен."
  TRANSLATIONS["ru,validator_node_info"]="Validator Node: производство блоков, нужен вайтлист и ключ подписи."
  TRANSLATIONS["ru,check_updates_title"]="Проверка обновлений"
  TRANSLATIONS["ru,check_updates_latest"]="Последняя версия Tempo: %s"
  TRANSLATIONS["ru,check_updates_current"]="Текущая установленная версия: %s"
  TRANSLATIONS["ru,check_updates_newer"]="Доступна новая версия!"
  TRANSLATIONS["ru,check_updates_current_latest"]="У вас установлена последняя версия."
  TRANSLATIONS["ru,option_stop"]="9. Остановить контейнер"
  TRANSLATIONS["ru,option_start"]="10. Запустить контейнер"
  TRANSLATIONS["ru,option_check_sync"]="11. Проверка синхронизации и блоков"
  TRANSLATIONS["ru,option_disk"]="12. Проверить занимаемое место на диске"
  TRANSLATIONS["ru,disk_usage"]="Используемое место на диске"
  TRANSLATIONS["ru,disk_usage_data"]="Tempo (%s) — данные:"
  TRANSLATIONS["ru,disk_usage_keys"]="Tempo (%s) — ключи:"
  TRANSLATIONS["ru,disk_usage_container_off"]="Контейнер не запущен; размер на хосте:"
  TRANSLATIONS["ru,select_node_which"]="Выберите ноду:"
  TRANSLATIONS["ru,select_node_rpc"]="1) RPC (%s/rpc)"
  TRANSLATIONS["ru,select_node_validator"]="2) Validator (%s/validator)"
  TRANSLATIONS["ru,select_node_cancel"]="0) Возврат в основное меню"
  TRANSLATIONS["ru,status_running"]="работает"
  TRANSLATIONS["ru,status_stopped"]="остановлен"
  TRANSLATIONS["ru,node_not_installed_any"]="Нода Tempo не установлена (нет docker-compose в %s или подкаталогах)."
  TRANSLATIONS["ru,stop_done"]="Контейнер остановлен."
  TRANSLATIONS["ru,start_done"]="Контейнер запущен."
  TRANSLATIONS["ru,check_sync_title"]="Проверка синхронизации и блоков (RPC: %s)"
  TRANSLATIONS["ru,check_sync_peers"]="Количество пиров (должно быть > 0):"
  TRANSLATIONS["ru,check_sync_block_height"]="Номер блока (должен расти):"
  TRANSLATIONS["ru,check_sync_block_info"]="Последний блок:"
  TRANSLATIONS["ru,check_sync_no_compose"]="Нода не установлена (нет docker-compose)."
  TRANSLATIONS["ru,check_sync_cast_required"]="Установите Foundry (cast) для проверки RPC: https://getfoundry.sh"
  TRANSLATIONS["ru,check_sync_rpc_failed"]="Ошибка RPC. Нода запущена и доступна по адресу %s?"
  TRANSLATIONS["ru,check_sync_menu_title"]="Проверка синхронизации и блоков (RPC: %s)"
  TRANSLATIONS["ru,check_sync_sub_peers"]="1. Количество пиров (должно быть > 0)"
  TRANSLATIONS["ru,check_sync_sub_block_number"]="2. Номер блока (должен расти)"
  TRANSLATIONS["ru,check_sync_sub_block"]="3. Информация о последнем блоке"
  TRANSLATIONS["ru,check_sync_sub_sync_status"]="4. Статус синхронизации (eth_syncing, этапы Reth)"
  TRANSLATIONS["ru,check_sync_back"]="0) Возврат в основное меню"
  TRANSLATIONS["ru,sync_status_title"]="Статус синхронизации (eth_syncing)"
  TRANSLATIONS["ru,sync_status_synced"]="Нода полностью синхронизирована (eth_syncing = false)."
  TRANSLATIONS["ru,sync_status_syncing"]="Нода синхронизируется (Reth)."
  TRANSLATIONS["ru,sync_status_blocks"]="Блоки: старт %s, текущий %s, макс. %s"
  TRANSLATIONS["ru,sync_status_progress"]="Прогресс: %s%%"
  TRANSLATIONS["ru,sync_status_network"]="Сеть (Moderato RPC): блок %s"
  TRANSLATIONS["ru,sync_status_lag"]="Отставание от сети: %s блоков"
  TRANSLATIONS["ru,sync_status_stages"]="Этапы Reth (этап → блок):"
  TRANSLATIONS["ru,sync_status_warp"]="Warp: %s / %s чанков"
  TRANSLATIONS["ru,sync_status_rpc_failed"]="Ошибка RPC. Нода запущена?"
  TRANSLATIONS["ru,checking_deps"]="Проверка зависимостей..."
  TRANSLATIONS["ru,missing_tools"]="Отсутствуют:"
  TRANSLATIONS["ru,install_prompt"]="Установить недостающие зависимости сейчас? (Y/n): "
  TRANSLATIONS["ru,installed"]="установлен"
  TRANSLATIONS["ru,not_installed"]="не установлен"
  TRANSLATIONS["ru,missing_required"]="Не хватает обязательных зависимостей. Выход."
  TRANSLATIONS["ru,installing_docker"]="Установка Docker..."
  TRANSLATIONS["ru,installing_compose"]="Установка Docker Compose..."
  TRANSLATIONS["ru,install_docker_prompt"]="Установить Docker? (y/n) "
  TRANSLATIONS["ru,install_compose_prompt"]="Установить Docker Compose? (y/n) "
  TRANSLATIONS["ru,compose_required"]="Требуется Docker Compose. Выход."
  TRANSLATIONS["ru,docker_installed"]="Docker установлен."
  TRANSLATIONS["ru,compose_installed"]="Docker Compose установлен."
  TRANSLATIONS["ru,installing_curl"]="Установка curl..."
  TRANSLATIONS["ru,installing_jq"]="Установка jq..."
  TRANSLATIONS["ru,installing_lz4"]="Установка lz4..."
  TRANSLATIONS["ru,installing_utils"]="Установка grep/sed..."
  TRANSLATIONS["ru,installing_wget"]="Установка wget..."
  TRANSLATIONS["ru,installing_tar"]="Установка tar..."
  TRANSLATIONS["ru,installing_git"]="Установка git..."
  TRANSLATIONS["ru,installing_make"]="Установка make..."
  TRANSLATIONS["ru,installing_pv"]="Установка pv..."
  TRANSLATIONS["ru,installing_rsync"]="Установка rsync..."

  # Turkish (based on English phrases)
  TRANSLATIONS["tr,title"]="========= Tempo Node (Moderato) ========="
  TRANSLATIONS["tr,option1"]="1. Tempo RPC Node kur (Docker)"
  TRANSLATIONS["tr,option1b"]="2. Tempo Validator Node kur (Docker)"
  TRANSLATIONS["tr,option_snap"]="3. Snapshot: indir / sürüm seç ve node yeniden başlat"
  TRANSLATIONS["tr,option2"]="4. Node sürümü düşür"
  TRANSLATIONS["tr,option3"]="5. Node sürümü"
  TRANSLATIONS["tr,option4"]="6. Logları görüntüle"
  TRANSLATIONS["tr,option0"]="0. Çıkış"
  TRANSLATIONS["tr,choose_option"]="Seçin:"
  TRANSLATIONS["tr,invalid_choice"]="Geçersiz seçim."
  TRANSLATIONS["tr,goodbye"]="Hoşça kalın."
  TRANSLATIONS["tr,checking_docker"]="Docker kontrol ediliyor..."
  TRANSLATIONS["tr,docker_not_found"]="Docker yüklü değil."
  TRANSLATIONS["tr,docker_required"]="Docker gerekli. Çıkılıyor."
  TRANSLATIONS["tr,docker_found"]="Docker bulundu."
  TRANSLATIONS["tr,checking_ports"]="Portlar kontrol ediliyor..."
  TRANSLATIONS["tr,port_busy"]="Port kullanımda."
  TRANSLATIONS["tr,port_free"]="Port boş."
  TRANSLATIONS["tr,enter_fee_recipient"]="FEE_RECIPIENT girin (ödüller için EVM adresi, 0x ile): "
  TRANSLATIONS["tr,fee_recipient_required"]="FEE_RECIPIENT gerekli. Çıkılıyor."
  TRANSLATIONS["tr,creating_dirs"]="Veri ve anahtar dizinleri oluşturuluyor..."
  TRANSLATIONS["tr,generating_key"]="Consensus imza anahtarı oluşturuluyor..."
  TRANSLATIONS["tr,key_exists"]="İmza anahtarı zaten var, atlanıyor."
  TRANSLATIONS["tr,downloading_snapshot"]="Zincir anlık görüntüsü indiriliyor (zaman alabilir)..."
  TRANSLATIONS["tr,snapshot_retry"]="Snapshot indirme başarısız (deneme %s/%s). 15 saniye sonra tekrar deneniyor..."
  TRANSLATIONS["tr,snapshot_failed"]="%s denemeden sonra snapshot indirme başarısız. Ağ bağlantınızı kontrol edip tekrar deneyin."
  TRANSLATIONS["tr,pulling_image"]="Docker imajı çekiliyor..."
  TRANSLATIONS["tr,creating_compose"]="docker-compose.yml oluşturuluyor..."
  TRANSLATIONS["tr,starting_node"]="Tempo node başlatılıyor..."
  TRANSLATIONS["tr,install_done"]="Kurulum tamamlandı."
  TRANSLATIONS["tr,rpc_info"]="RPC: http://%s:%s (yerel)"
  TRANSLATIONS["tr,p2p_info"]="P2P: tcp/udp %s"
  TRANSLATIONS["tr,node_not_installed"]="Tempo node yüklü değil (%s içinde docker-compose yok)"
  TRANSLATIONS["tr,downgrade_title"]="Tempo node sürüm düşür"
  TRANSLATIONS["tr,downgrade_fetching"]="Mevcut sürümler alınıyor..."
  TRANSLATIONS["tr,downgrade_available"]="Mevcut sürümler (numara girin):"
  TRANSLATIONS["tr,downgrade_show_all"]="Tüm sürümleri göster (yalnızca X.Y.Z)"
  TRANSLATIONS["tr,downgrade_invalid_choice"]="Geçersiz seçim."
  TRANSLATIONS["tr,downgrade_selected"]="Seçilen sürüm:"
  TRANSLATIONS["tr,downgrade_fetch_error"]="Sürüm listesi alınamadı. Listeden seçin veya özel etiket girin."
  TRANSLATIONS["tr,downgrade_folder_error"]="Dizin %s bulunamadı."
  TRANSLATIONS["tr,downgrade_pulling"]="İmaj çekiliyor"
  TRANSLATIONS["tr,downgrade_pull_error"]="İmaj çekilemedi."
  TRANSLATIONS["tr,downgrade_stopping"]="Konteynerler durduruluyor..."
  TRANSLATIONS["tr,downgrade_removing_data"]="Zincir verisi siliniyor..."
  TRANSLATIONS["tr,downgrade_downloading_snapshot"]="%s zinciri için snapshot yeniden indiriliyor..."
  TRANSLATIONS["tr,downgrade_updating"]="docker-compose güncelleniyor..."
  TRANSLATIONS["tr,downgrade_starting"]="Node başlatılıyor"
  TRANSLATIONS["tr,downgrade_success"]="Node sürümü düşürüldü:"
  TRANSLATIONS["tr,version_title"]="Tempo node sürümü"
  TRANSLATIONS["tr,container_not_found"]="Tempo konteyneri bulunamadı."
  TRANSLATIONS["tr,container_found"]="Konteyner:"
  TRANSLATIONS["tr,node_version"]="Tempo node sürümü:"
  TRANSLATIONS["tr,version_failed"]="Sürüm alınamadı."
  TRANSLATIONS["tr,view_logs"]="Tempo loglarını görüntüle"
  TRANSLATIONS["tr,press_ctrlc"]="Loglardan çıkmak için Ctrl+C."
  TRANSLATIONS["tr,return_menu"]="Menüye dönülüyor..."
  TRANSLATIONS["tr,option6"]="7. Node'u kaldır"
  TRANSLATIONS["tr,remove_title"]="Tempo node kaldır"
  TRANSLATIONS["tr,remove_not_installed"]="Tempo node yüklü değil (%s içinde docker-compose yok)"
  TRANSLATIONS["tr,remove_confirm_full"]="Tam kaldırma: konteyner durdurulacak, veri, anahtarlar ve config silinecek. Onay için 'yes' yazın: "
  TRANSLATIONS["tr,remove_confirm_container"]="Yalnızca konteyner kaldır (veri ve anahtarlar kalacak). Onay için 'yes' yazın: "
  TRANSLATIONS["tr,remove_cancelled"]="Ana menüye dönülüyor."
  TRANSLATIONS["tr,remove_stopping"]="Konteyner durduruluyor ve kaldırılıyor..."
  TRANSLATIONS["tr,remove_deleting"]="Veri, anahtarlar ve config siliniyor..."
  TRANSLATIONS["tr,remove_done"]="Node kaldırıldı."
  TRANSLATIONS["tr,remove_done_kept"]="Konteyner kaldırıldı. Veri ve anahtarlar %s içinde saklandı"
  TRANSLATIONS["tr,remove_option_container"]="1) Yalnızca konteyneri kaldır (veri ve anahtarlar kalsın)"
  TRANSLATIONS["tr,remove_option_full"]="2) Tam kaldırma (veri, anahtarlar, config silinsin)"
  TRANSLATIONS["tr,remove_choose"]="1 veya 2: "
  TRANSLATIONS["tr,update_installer_title"]="Kurulum scriptini güncelle"
  TRANSLATIONS["tr,update_installer_no_url"]="SCRIPT_URL ayarlanmamış. Kurulum scripti güncellenemiyor."
  TRANSLATIONS["tr,update_installer_downloading"]="En son kurulum scripti indiriliyor..."
  TRANSLATIONS["tr,update_installer_failed"]="Kurulum scripti güncellemesi indirilemedi"
  TRANSLATIONS["tr,update_installer_no_version"]="Uzak sürüm belirlenemedi"
  TRANSLATIONS["tr,update_installer_up_to_date"]="Kurulum scripti zaten güncel (sürüm %s)"
  TRANSLATIONS["tr,update_installer_updating"]="%s'den %s'ye güncelleniyor..."
  TRANSLATIONS["tr,update_installer_failed_copy"]="Kurulum scripti güncellenemedi. Sudo ile çalıştırmayı deneyin."
  TRANSLATIONS["tr,update_installer_success"]="✓ Kurulum scripti başarıyla %s sürümüne güncellendi"
  TRANSLATIONS["tr,installer_version"]="Kurulum scripti sürümü: %s"
  TRANSLATIONS["tr,option8"]="8. Güncellemeleri kontrol et"
  TRANSLATIONS["tr,snapshot_title"]="Snapshot: sürüm seç, indir, node yeniden başlat"
  TRANSLATIONS["tr,snapshot_list"]="%s zinciri için mevcut snapshotlar (chainId %s):"
  TRANSLATIONS["tr,snapshot_latest"]="En son snapshot'ı kullan (önerilen)"
  TRANSLATIONS["tr,snapshot_enter_url"]="Snapshot URL'sini manuel gir"
  TRANSLATIONS["tr,snapshot_extract_local"]="Yerel dosyadan aç (.tar.lz4 yolu)"
  TRANSLATIONS["tr,snapshot_choice"]="Seçim (numara, 0=son, u=URL, e=yerel dosya): "
  TRANSLATIONS["tr,lz4_no_threading"]="lz4 sürümünüz çoklu iş parçacığını (-T) desteklemiyor."
  TRANSLATIONS["tr,lz4_update_ask"]="lz4 kaynak kodundan güncellensin mi (-T desteği)? (y/n): "
  TRANSLATIONS["tr,snapshot_downloading"]="Snapshot indiriliyor..."
  TRANSLATIONS["tr,snapshot_done"]="Snapshot başarıyla indirildi."
  TRANSLATIONS["tr,snapshot_restart_ask"]="Node şimdi yeniden başlatılsın mı? (y/n): "
  TRANSLATIONS["tr,snapshot_restarting"]="Node yeniden başlatılıyor..."
  TRANSLATIONS["tr,snapshot_no_compose"]="Node yüklü değil (docker-compose yok). Önce RPC veya Validator kurun."
  TRANSLATIONS["tr,rpc_node_info"]="RPC Node: zincir senkronize eder, API sunar; validator anahtarı gerekmez."
  TRANSLATIONS["tr,validator_node_info"]="Validator Node: blok üretir; whitelist ve imza anahtarı gerekir."
  TRANSLATIONS["tr,check_updates_title"]="Güncellemeleri kontrol et"
  TRANSLATIONS["tr,check_updates_latest"]="En son Tempo sürümü: %s"
  TRANSLATIONS["tr,check_updates_current"]="Mevcut kurulu sürüm: %s"
  TRANSLATIONS["tr,check_updates_newer"]="Yeni bir sürüm mevcut!"
  TRANSLATIONS["tr,check_updates_current_latest"]="En son sürümü çalıştırıyorsunuz."
  TRANSLATIONS["tr,option_stop"]="9. Konteyneri durdur"
  TRANSLATIONS["tr,option_start"]="10. Konteyneri başlat"
  TRANSLATIONS["tr,option_check_sync"]="11. Senkronizasyon ve blok kontrolü"
  TRANSLATIONS["tr,option_disk"]="12. Disk kullanımını kontrol et"
  TRANSLATIONS["tr,disk_usage"]="Disk kullanımı"
  TRANSLATIONS["tr,disk_usage_data"]="Tempo (%s) — veri:"
  TRANSLATIONS["tr,disk_usage_keys"]="Tempo (%s) — anahtarlar:"
  TRANSLATIONS["tr,disk_usage_container_off"]="Konteyner çalışmıyor; ana bilgisayar yolu boyutu:"
  TRANSLATIONS["tr,select_node_which"]="Hangi node?"
  TRANSLATIONS["tr,select_node_rpc"]="1) RPC (%s/rpc)"
  TRANSLATIONS["tr,select_node_validator"]="2) Validator (%s/validator)"
  TRANSLATIONS["tr,select_node_cancel"]="0) Ana menüye dön"
  TRANSLATIONS["tr,status_running"]="çalışıyor"
  TRANSLATIONS["tr,status_stopped"]="durduruldu"
  TRANSLATIONS["tr,node_not_installed_any"]="Tempo node yüklü değil (%s veya alt dizinlerde docker-compose yok)."
  TRANSLATIONS["tr,stop_done"]="Konteyner durduruldu."
  TRANSLATIONS["tr,start_done"]="Konteyner başlatıldı."
  TRANSLATIONS["tr,check_sync_title"]="Senkronizasyon ve blok kontrolü (RPC: %s)"
  TRANSLATIONS["tr,check_sync_peers"]="Eş sayısı (sıfırdan farklı olmalı):"
  TRANSLATIONS["tr,check_sync_block_height"]="Blok yüksekliği (artmalı):"
  TRANSLATIONS["tr,check_sync_block_info"]="Son blok:"
  TRANSLATIONS["tr,check_sync_no_compose"]="Node yüklü değil (docker-compose yok)."
  TRANSLATIONS["tr,check_sync_cast_required"]="RPC kontrolü için Foundry (cast) kurun: https://getfoundry.sh"
  TRANSLATIONS["tr,check_sync_rpc_failed"]="RPC isteği başarısız. Node çalışıyor mu, %s erişilebilir mi?"
  TRANSLATIONS["tr,check_sync_menu_title"]="Senkronizasyon ve blok kontrolü (RPC: %s)"
  TRANSLATIONS["tr,check_sync_sub_peers"]="1. Eş sayısı (sıfırdan farklı olmalı)"
  TRANSLATIONS["tr,check_sync_sub_block_number"]="2. Blok yüksekliği (artmalı)"
  TRANSLATIONS["tr,check_sync_sub_block"]="3. Son blok bilgisi"
  TRANSLATIONS["tr,check_sync_sub_sync_status"]="4. Senkronizasyon durumu (eth_syncing, Reth aşamaları)"
  TRANSLATIONS["tr,check_sync_back"]="0) Ana menüye dön"
  TRANSLATIONS["tr,sync_status_title"]="Senkronizasyon durumu (eth_syncing)"
  TRANSLATIONS["tr,sync_status_synced"]="Node tam senkronize (eth_syncing = false)."
  TRANSLATIONS["tr,sync_status_syncing"]="Node senkronize ediyor (Reth)."
  TRANSLATIONS["tr,sync_status_blocks"]="Bloklar: başlangıç %s, mevcut %s, en yüksek %s"
  TRANSLATIONS["tr,sync_status_progress"]="İlerleme: %s%%"
  TRANSLATIONS["tr,sync_status_network"]="Ağ (Moderato RPC): blok %s"
  TRANSLATIONS["tr,sync_status_lag"]="Ağdan gecikme: %s blok"
  TRANSLATIONS["tr,sync_status_stages"]="Reth aşamaları (aşama → blok):"
  TRANSLATIONS["tr,sync_status_warp"]="Warp: %s / %s chunk"
  TRANSLATIONS["tr,sync_status_rpc_failed"]="RPC isteği başarısız. Node çalışıyor mu?"
  TRANSLATIONS["tr,checking_deps"]="Gerekli bağımlılıklar kontrol ediliyor..."
  TRANSLATIONS["tr,missing_tools"]="Eksik:"
  TRANSLATIONS["tr,install_prompt"]="Eksik bağımlılıklar şimdi yüklensin mi? (Y/n): "
  TRANSLATIONS["tr,installed"]="yüklü"
  TRANSLATIONS["tr,not_installed"]="yüklü değil"
  TRANSLATIONS["tr,missing_required"]="Gerekli bağımlılıklar eksik. Çıkılıyor."
  TRANSLATIONS["tr,installing_docker"]="Docker yükleniyor..."
  TRANSLATIONS["tr,installing_compose"]="Docker Compose yükleniyor..."
  TRANSLATIONS["tr,install_docker_prompt"]="Docker yüklensin mi? (y/n) "
  TRANSLATIONS["tr,install_compose_prompt"]="Docker Compose yüklensin mi? (y/n) "
  TRANSLATIONS["tr,compose_required"]="Docker Compose gerekli. Çıkılıyor."
  TRANSLATIONS["tr,docker_installed"]="Docker yüklendi."
  TRANSLATIONS["tr,compose_installed"]="Docker Compose yüklendi."
  TRANSLATIONS["tr,installing_curl"]="curl yükleniyor..."
  TRANSLATIONS["tr,installing_jq"]="jq yükleniyor..."
  TRANSLATIONS["tr,installing_lz4"]="lz4 yükleniyor..."
  TRANSLATIONS["tr,installing_utils"]="grep/sed yükleniyor..."
  TRANSLATIONS["tr,installing_wget"]="wget yükleniyor..."
  TRANSLATIONS["tr,installing_tar"]="tar yükleniyor..."
  TRANSLATIONS["tr,installing_git"]="git yükleniyor..."
  TRANSLATIONS["tr,installing_make"]="make yükleniyor..."
  TRANSLATIONS["tr,installing_pv"]="pv yükleniyor..."
  TRANSLATIONS["tr,installing_rsync"]="rsync yükleniyor..."
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions for colored output
info() {
    echo -e "${GREEN}info${NC}: $1"
}

warn() {
    echo -e "${YELLOW}warn${NC}: $1"
}

error() {
    echo -e "${RED}error${NC}: $1" >&2
    exit 1
}

# Defaults (Moderato testnet)
CHAIN="${CHAIN:-moderato}"
TEMPO_HOME="${TEMPO_HOME:-$HOME/tempo}"
DATADIR="${DATADIR:-$TEMPO_HOME/data}"
KEYDIR="${KEYDIR:-$TEMPO_HOME/keys}"
HTTP_ADDR="${HTTP_ADDR:-0.0.0.0}"
HTTP_PORT="${HTTP_PORT:-8545}"
P2P_PORT="${P2P_PORT:-30303}"
DISCOVERY_ADDR="${DISCOVERY_ADDR:-0.0.0.0}"
DISCOVERY_PORT="${DISCOVERY_PORT:-30303}"
TEMPO_IMAGE="${TEMPO_IMAGE:-ghcr.io/tempoxyz/tempo:1.1.4}"
CONTAINER_NAME="${CONTAINER_NAME:-tempo}"
SNAPSHOTS_API="${SNAPSHOTS_API:-https://snapshots.tempoxyz.dev/api/snapshots}"
REPO="tempoxyz/tempo"
# Optional: Set SCRIPT_URL if installer is hosted online for update checks
SCRIPT_URL="${SCRIPT_URL:-}"
# Optional: Telegram (set in .env-tempo)
TG_BOT_TOKEN="${TG_BOT_TOKEN:-}"
TG_CHAT_ID="${TG_CHAT_ID:-}"

# Load .env-tempo from script directory or TEMPO_HOME (later overrides earlier)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
if [[ -f "$SCRIPT_DIR/.env-tempo" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/.env-tempo"
  set +a
fi
if [[ -f "$TEMPO_HOME/.env-tempo" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$TEMPO_HOME/.env-tempo"
  set +a
fi

# Re-apply defaults after .env-tempo so unset vars keep defaults
CHAIN="${CHAIN:-moderato}"
TEMPO_HOME="${TEMPO_HOME:-$HOME/tempo}"
DATADIR="${DATADIR:-$TEMPO_HOME/data}"
KEYDIR="${KEYDIR:-$TEMPO_HOME/keys}"
HTTP_ADDR="${HTTP_ADDR:-0.0.0.0}"
HTTP_PORT="${HTTP_PORT:-8545}"
P2P_PORT="${P2P_PORT:-30303}"
DISCOVERY_ADDR="${DISCOVERY_ADDR:-0.0.0.0}"
DISCOVERY_PORT="${DISCOVERY_PORT:-30303}"
TEMPO_IMAGE="${TEMPO_IMAGE:-ghcr.io/tempoxyz/tempo:1.1.4}"
CONTAINER_NAME="${CONTAINER_NAME:-tempo}"
SNAPSHOTS_API="${SNAPSHOTS_API:-https://snapshots.tempoxyz.dev/api/snapshots}"
SCRIPT_URL="${SCRIPT_URL:-}"
TG_BOT_TOKEN="${TG_BOT_TOKEN:-}"
TG_CHAT_ID="${TG_CHAT_ID:-}"

# RPC node ports (https://docs.tempo.xyz/guide/node/system-requirements#ports)
RPC_HTTP_PORT="${RPC_HTTP_PORT:-8545}"
RPC_WS_PORT="${RPC_WS_PORT:-8546}"
RPC_P2P_PORT="${RPC_P2P_PORT:-30303}"
RPC_DISCOVERY_PORT="${RPC_DISCOVERY_PORT:-30303}"
RPC_METRICS_PORT="${RPC_METRICS_PORT:-9000}"

# Validator node ports (same defaults as docs; override when running both on one machine)
VALIDATOR_HTTP_PORT="${VALIDATOR_HTTP_PORT:-8545}"
VALIDATOR_WS_PORT="${VALIDATOR_WS_PORT:-8546}"
VALIDATOR_P2P_PORT="${VALIDATOR_P2P_PORT:-30303}"
VALIDATOR_CONSENSUS_PORT="${VALIDATOR_CONSENSUS_PORT:-8000}"
VALIDATOR_DISCOVERY_PORT="${VALIDATOR_DISCOVERY_PORT:-30303}"
VALIDATOR_METRICS_PORT="${VALIDATOR_METRICS_PORT:-9000}"

# Tools required by the script (docker and docker-compose are checked separately)
# curl,jq: API snapshots, GitHub, update check; lz4,tar,wget: snapshot download/extract; grep,sed: parsing; git,make: build lz4 from source; pv,rsync: progress
REQUIRED_TOOLS=(curl jq lz4 grep sed wget tar git make pv rsync)

# Chain name -> chainId for API (https://snapshots.tempoxyz.dev/api/snapshots)
# Moderato = testnet 42431, mainnet = 4217
chain_to_chain_id() {
  local ch="${1:-}"
  case "$ch" in
    moderato) echo "42431" ;;
    mainnet)  echo "4217" ;;
    *) [[ "$ch" =~ ^[0-9]+$ ]] && echo "$ch" || echo "" ;;
  esac
}

# Get snapshot archiveUrl from API for given image and chainId; empty if not found or no curl/jq
get_snapshot_url_from_api() {
  local img="$1" cid="$2" json
  [[ -z "$cid" ]] && return
  if ! need_cmd curl || ! need_cmd jq; then
    return
  fi
  json=$(curl -sL --connect-timeout 10 --max-time 30 "$SNAPSHOTS_API" 2>/dev/null) || return
  echo "$json" | jq -r --arg img "$img" --arg cid "$cid" \
    '[.[] | select(.image == $img and .chainId == $cid)][0].archiveUrl // empty' 2>/dev/null
}

# List snapshots from API for chainId; output "index|date|block|archiveUrl|image" one per line (newest first).
# If image_filter is set, filter by image; otherwise return all for chainId.
list_snapshots_from_api() {
  local cid="$1" image_filter="${2:-}" json
  [[ -z "$cid" ]] && return
  if ! need_cmd curl || ! need_cmd jq; then
    return
  fi
  json=$(curl -sL --connect-timeout 10 --max-time 30 "$SNAPSHOTS_API" 2>/dev/null) || return
  if [[ -n "$image_filter" ]]; then
    echo "$json" | jq -r --arg cid "$cid" --arg img "$image_filter" \
      '[.[] | select(.chainId == $cid and .image == $img)] | sort_by(.timestamp) | reverse | .[0:30][] | "\(.date)|\(.block)|\(.archiveUrl)|\(.image)"' 2>/dev/null
  else
    echo "$json" | jq -r --arg cid "$cid" \
      '[.[] | select(.chainId == $cid)] | sort_by(.timestamp) | reverse | .[0:30][] | "\(.date)|\(.block)|\(.archiveUrl)|\(.image)"' 2>/dev/null
  fi
}

# Return 0 if lz4 supports multi-threading (-T), else 1. Requires lz4 to be in PATH.
lz4_supports_threading() {
  need_cmd lz4 || return 1
  lz4 -H 2>&1 | grep -qE '\-T\b|--threads' || return 1
  return 0
}

# Build and install lz4 from source (multi-threaded support). Asks for confirmation on failure.
# Uses clean build dir, then: clone, make -j$(nproc), make install, ldconfig, hash -r.
install_lz4_from_source() {
  local build_dir="/tmp/lz4-build"
  if ! need_cmd git; then
    warn "git is required to build lz4. Install git and try again."
    return 1
  fi
  if ! need_cmd make; then
    warn "make is required to build lz4. Install build-essential / make and try again."
    return 1
  fi
  info "Removing previous build dir (if any)..."
  rm -rf "$build_dir"
  mkdir -p "$build_dir" || { warn "Cannot create $build_dir"; return 1; }
  info "Cloning lz4 from GitHub..."
  if ! git clone --depth 1 https://github.com/lz4/lz4.git "$build_dir"; then
    warn "git clone failed. Check network and try again."
    rm -rf "$build_dir"
    return 1
  fi
  if ! ( cd "$build_dir" && info "Building lz4 (make -j$(nproc))..." && make -j"$(nproc)" ); then
    warn "make failed."
    rm -rf "$build_dir"
    return 1
  fi
  info "Installing lz4 (may ask for sudo)..."
  if ! ( cd "$build_dir" && make install ) 2>/dev/null; then
    if need_cmd sudo && ( cd "$build_dir" && sudo make install ); then
      : # ok
    else
      warn "make install failed. Run manually: cd $build_dir && sudo make install"
      rm -rf "$build_dir"
      return 1
    fi
  fi
  rm -rf "$build_dir"
  if need_cmd ldconfig; then
    ldconfig 2>/dev/null || sudo ldconfig 2>/dev/null || true
  fi
  hash -r 2>/dev/null || true
  if need_cmd lz4; then
    info "lz4 version: $(lz4 --version 2>/dev/null || echo 'unknown')"
  fi
  return 0
}

# Extract .tar.lz4 archive to data_dir using lz4_cmd. Shows progress via pv if available.
# Returns 0 on success. Usage: snapshot_extract_with_progress "$archive_path" "$data_dir" "$lz4_cmd"
snapshot_extract_with_progress() {
  local archive_path="$1" data_dir="$2" lz4_cmd="$3" size
  if need_cmd pv && [[ -f "$archive_path" ]]; then
    size=$(stat -c%s "$archive_path" 2>/dev/null || stat -f%z "$archive_path" 2>/dev/null)
    if [[ -n "$size" && "$size" -gt 0 ]]; then
      set +e
      pv -s "$size" "$archive_path" | $lz4_cmd | tar -xf - -C "$data_dir"
      local p0=${PIPESTATUS[0]} p1=${PIPESTATUS[1]} p2=${PIPESTATUS[2]} ret=0
      [[ "$p0" -ne 0 ]] && ret=$p0
      [[ "$p1" -ne 0 ]] && ret=$p1
      [[ "$p2" -ne 0 ]] && ret=$p2
      set -e
      return $ret
    fi
  fi
  tar --use-compress-program="$lz4_cmd" -xf "$archive_path" -C "$data_dir"
}

# Check that destination has enough free space for copying src_dir. Error with message if not.
# Uses du -s and df -k (KB). Margin 1 GB. Returns 0 if OK, calls error() and exits if not.
check_disk_space_for_copy() {
  local src_dir="$1" dst_dir="$2"
  local src_kb dest_avail_kb margin_kb=1048576
  src_kb=$(du -s "$src_dir" 2>/dev/null | cut -f1)
  dest_avail_kb=$(df -k "$dst_dir" 2>/dev/null | awk 'NR==2 {print $4}')
  [[ -z "$src_kb" || -z "$dest_avail_kb" ]] && return 0
  if [[ "$dest_avail_kb" -lt $((src_kb + margin_kb)) ]]; then
    error "Not enough space on destination. Need ~$((src_kb / 1024 / 1024)) GB free, have ~$((dest_avail_kb / 1024 / 1024)) GB. Free space or use another disk (DATADIR)."
  fi
}

# Copy snapshot data from src_dir to dst_dir. Shows progress via rsync if available.
# Checks free space first. dst_dir must exist. Usage: snapshot_copy_with_progress "$src_dir" "$dst_dir"
snapshot_copy_with_progress() {
  local src_dir="$1" dst_dir="$2"
  check_disk_space_for_copy "$src_dir" "$dst_dir"
  if need_cmd rsync; then
    rsync -ah --info=progress2 "$src_dir"/ "$dst_dir"/
  else
    cp -a "$src_dir"/. "$dst_dir"
  fi
}

# Run snapshot download with retries (wget + lz4 + tar, per docs: https://docs.tempo.xyz/guide/node/rpc#manually-downloading-snapshots)
# Downloads archive to a temp dir, removes data_dir, then extracts directly into data_dir to save disk space.
# Uses wget -c so connection drops can be resumed on next attempt.
# Uses lz4 -d -T0 when supported for multi-threaded decompression.
run_snapshot_download_with_retry() {
  local img="$1" data_dir="$2" snapshot_url="$3" chain="$4"
  local max_attempts=5 attempt=1 chain_id archive_path lz4_cmd tmpdir

  if ! need_cmd wget; then
    error "wget is required for snapshot download. Install wget and try again."
  fi
  if ! need_cmd lz4; then
    error "lz4 is required for snapshot download. Install lz4 (e.g. apt install lz4 / yum install lz4) and try again."
  fi

  # Check multi-threading support; offer to update from source if missing
  if lz4_supports_threading; then
    lz4_cmd="lz4 -d -T0"
  else
    warn "$(t "lz4_no_threading")"
    read -e -p "$(t "lz4_update_ask")" lz4_yn
    if [[ "$lz4_yn" =~ ^[yY] ]]; then
      if install_lz4_from_source && lz4_supports_threading; then
        lz4_cmd="lz4 -d -T0"
      else
        warn "Using single-threaded lz4 -d."
        lz4_cmd="lz4 -d"
      fi
    else
      lz4_cmd="lz4 -d"
    fi
  fi

  # Resolve URL from API if not provided
  if [[ -z "${snapshot_url:-}" ]]; then
    chain_id=$(chain_to_chain_id "$chain")
    snapshot_url=$(get_snapshot_url_from_api "$img" "$chain_id")
    if [[ -z "${snapshot_url:-}" ]]; then
      error "Could not get snapshot URL for chain $chain. Set SNAPSHOTS_API or check network."
    fi
    info "Using snapshot URL from API"
  fi

  tmpdir=$(mktemp -d) || error "Could not create temp directory for snapshot archive."
  trap 'rm -rf "${tmpdir:?}"' EXIT
  archive_path="$tmpdir/snapshot.tar.lz4"

  while [[ $attempt -le $max_attempts ]]; do
    info "Downloading snapshot from URL (attempt $attempt/$max_attempts, resume supported)..."
    set +e
    # Download to file with resume (-c): on next attempt wget continues from where it left off
    wget -c --connect-timeout=10 -O "$archive_path" "$snapshot_url"
    local wget_ret=$?
    set -e
    if [[ $wget_ret -ne 0 ]]; then
      warn "Snapshot download failed (attempt $attempt/$max_attempts, wget exit $wget_ret)"
      if [[ $attempt -lt $max_attempts ]]; then
        printf "$(t "snapshot_retry")\n" "$attempt" "$max_attempts"
        sleep 15
      fi
      attempt=$((attempt + 1))
      continue
    fi
    info "Removing old data and extracting snapshot into $data_dir..."
    rm -rf "${data_dir:?}"
    mkdir -p "$data_dir"
    set +e
    snapshot_extract_with_progress "$archive_path" "$data_dir" "$lz4_cmd"
    local tar_ret=$?
    set -e
    if [[ $tar_ret -eq 0 ]]; then
      trap - EXIT
      rm -rf "${tmpdir:?}"
      return 0
    fi
    warn "Snapshot extract failed (attempt $attempt/$max_attempts, tar exit $tar_ret)"
    if [[ $attempt -lt $max_attempts ]]; then
      printf "$(t "snapshot_retry")\n" "$attempt" "$max_attempts"
      sleep 15
    fi
    attempt=$((attempt + 1))
  done
  error "$(printf "$(t "snapshot_failed")" "$max_attempts")"
}

# Get latest release tag from GitHub
get_latest_tempo_version() {
  if ! need_cmd curl; then
    warn "curl not found. Cannot fetch latest version." >&2
    return 1
  fi

  local api_url="https://api.github.com/repos/$REPO/releases/latest"
  local version=$(curl -sSL --connect-timeout 10 --max-time 30 "$api_url" 2>/dev/null | \
    grep '"tag_name":' | head -n 1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/' || echo "")

  if [[ -z "$version" ]]; then
    warn "Failed to fetch latest version from GitHub" >&2
    return 1
  fi

  echo "$version"
}

need_cmd() { command -v "$1" >/dev/null 2>&1; }

# Send Telegram notification if TG_BOT_TOKEN and TG_CHAT_ID are set (e.g. from .env-tempo)
send_telegram() {
  local msg="$1"
  [[ -z "${TG_BOT_TOKEN:-}" || -z "${TG_CHAT_ID:-}" ]] && return 0
  if need_cmd curl; then
    curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
      --data-urlencode "text=$msg" -d "chat_id=${TG_CHAT_ID}" -d "disable_web_page_preview=true" \
      --connect-timeout 5 --max-time 10 >/dev/null 2>&1 || true
  fi
}

# Create template .env-tempo in TEMPO_HOME if missing (options 1 and 2).
# Content = .env.example. Do not overwrite if file already exists. Verify after create.
ensure_env_tempo_template() {
  local env_tempo="${TEMPO_HOME}/.env-tempo"
  # Do not re-create: if file exists, skip and confirm presence
  if [[ -f "$env_tempo" ]]; then
    info "Config file already exists: $env_tempo (skipping creation)"
    return 0
  fi
  info "Creating config template: $env_tempo"
  if [[ -f "$SCRIPT_DIR/.env.example" ]]; then
    cp "$SCRIPT_DIR/.env.example" "$env_tempo" || { warn "Failed to copy .env.example to $env_tempo"; return 1; }
  else
    cat > "$env_tempo" <<'ENVTEMPO'
# Tempo Node Installer — config (copy to .env-tempo and edit)
# Load order: ./install-tempo.sh loads SCRIPT_DIR/.env-tempo then TEMPO_HOME/.env-tempo

# --- Network / node ---
# Chain: moderato (testnet) or mainnet
CHAIN=moderato
# Node home directory (default: $HOME/tempo)
# TEMPO_HOME=$HOME/tempo
# Optional overrides (defaults: $TEMPO_HOME/data, $TEMPO_HOME/keys)
# DATADIR=
# KEYDIR=

# --- Ports (https://docs.tempo.xyz/guide/node/system-requirements#ports) ---
# 30303 Execution P2P, 8000 Consensus P2P, 8545 HTTP RPC, 8546 WebSocket RPC, 9000 Metrics
# Override when running RPC and Validator on one machine (e.g. VALIDATOR_HTTP_PORT=8547).
HTTP_ADDR=0.0.0.0
DISCOVERY_ADDR=0.0.0.0
# RPC: RPC_HTTP_PORT=8545 RPC_WS_PORT=8546 RPC_P2P_PORT=30303 RPC_METRICS_PORT=9000
# Validator: VALIDATOR_HTTP_PORT=8545 VALIDATOR_WS_PORT=8546 VALIDATOR_P2P_PORT=30303 VALIDATOR_CONSENSUS_PORT=8000 VALIDATOR_METRICS_PORT=9000

# --- Docker ---
# Default image tag
TEMPO_IMAGE=ghcr.io/tempoxyz/tempo:1.1.4
CONTAINER_NAME=tempo

# --- Snapshots API ---
# SNAPSHOTS_API=https://snapshots.tempoxyz.dev/api/snapshots

# --- Telegram (optional) ---
# Create bot via @BotFather, get token. Chat ID: use @userinfobot or getUpdates
# TG_BOT_TOKEN=
# TG_CHAT_ID=

# --- Installer update (optional) ---
# SCRIPT_URL=
ENVTEMPO
  fi
  if [[ ! -f "$env_tempo" ]]; then
    warn "Failed to create $env_tempo"
    return 1
  fi
  info "Config template created and present: $env_tempo"
  return 0
}

# Compare SemVer versions
# Returns 0 if $1 > $2, 1 otherwise
version_gt() {
    [ "$1" = "$2" ] && return 1

    # Remove 'v' prefix if present
    local ver1="${1#v}"
    local ver2="${2#v}"

    IFS=. read -r major1 minor1 patch1 <<EOF
$ver1
EOF
    IFS=. read -r major2 minor2 patch2 <<EOF
$ver2
EOF

    [ "$major1" -gt "$major2" ] && return 0
    [ "$major1" -lt "$major2" ] && return 1
    [ "$minor1" -gt "$minor2" ] && return 0
    [ "$minor1" -lt "$minor2" ] && return 1
    [ "$patch1" -gt "$patch2" ] && return 0
    [ "$patch1" -lt "$patch2" ] && return 1

    return 1
}

# Print installer version
print_version() {
    echo "$INSTALLER_VERSION"
    exit 0
}

# Check if installer script is up to date
check_installer_up_to_date() {
    # Skip check if curl not available or if SCRIPT_URL is not set
    if ! need_cmd curl || [[ -z "${SCRIPT_URL:-}" ]]; then
        return
    fi

    # Fetch the remote version
    local remote_version=$(curl -fsSL "$SCRIPT_URL" 2>/dev/null | \
        grep '^INSTALLER_VERSION=' | head -n 1 | sed -E 's/INSTALLER_VERSION="(.+)"/\1/' || echo "")

    if [[ -z "$remote_version" ]]; then
        return
    fi

    # Compare versions
    if version_gt "$remote_version" "$INSTALLER_VERSION"; then
        echo ""
        warn "Your installer version ($INSTALLER_VERSION) is outdated."
        warn "Latest version is $remote_version."
        warn "Please download the latest version from the repository."
        echo ""
    fi
}

# Update installer script itself (if SCRIPT_URL is set)
update_installer() {
    if [[ -z "${SCRIPT_URL:-}" ]]; then
        error "SCRIPT_URL not set. Cannot update installer."
    fi

    info "Updating installer script..."

    if ! need_cmd curl; then
        error "curl not found. Please install curl."
    fi

    # Create temporary file
    local tmp_file=$(mktemp)
    trap "rm -f $tmp_file" EXIT

    # Download latest installer script
    info "Downloading latest installer..."

    if ! curl -fsSL "$SCRIPT_URL" -o "$tmp_file" 2>/dev/null; then
        error "Failed to download installer update"
    fi

    # Extract remote version
    local remote_version=$(grep '^INSTALLER_VERSION=' "$tmp_file" | head -n 1 | sed -E 's/INSTALLER_VERSION="(.+)"/\1/' || echo "")

    if [[ -z "$remote_version" ]]; then
        error "Failed to determine remote version"
    fi

    # Check if update is needed
    if ! version_gt "$remote_version" "$INSTALLER_VERSION"; then
        info "Installer is already up to date (version $INSTALLER_VERSION)"
        exit 0
    fi

    # Replace current script with new version
    local script_path="${0:-install-tempo.sh}"
    info "Updating from $INSTALLER_VERSION to $remote_version..."
    if cp "$tmp_file" "$script_path" 2>/dev/null; then
        chmod 755 "$script_path"
    elif sudo cp "$tmp_file" "$script_path" 2>/dev/null; then
        sudo chmod 755 "$script_path"
    else
        error "Failed to update installer at $script_path. Try running with sudo."
    fi

    echo ""
    info "вњ“ Installer updated successfully to version $remote_version"
    exit 0
}

docker_compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    echo "docker compose"
  else
    echo "docker-compose"
  fi
}

check_docker() {
  echo -e "\n${CYAN}$(t "checking_docker")${NC}"
  if ! need_cmd docker; then
    echo -e "${RED}$(t "docker_not_found")${NC}"
    echo -e "${RED}$(t "docker_required")${NC}"
    exit 1
  fi
  if ! docker compose version >/dev/null 2>&1 && ! need_cmd docker-compose; then
    echo -e "${RED}docker compose or docker-compose required.${NC}"
    exit 1
  fi
  echo -e "${GREEN}$(t "docker_found")${NC}"
}

install_docker() {
  echo -e "\n${YELLOW}$(t "installing_docker")${NC}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker "$USER" 2>/dev/null || true
  rm -f get-docker.sh
  echo -e "\n${GREEN}$(t "docker_installed")${NC}"
}

install_docker_compose() {
  echo -e "\n${YELLOW}$(t "installing_compose")${NC}"
  local tag_name
  tag_name=$(curl -s https://api.github.com/repos/docker/compose/releases/latest 2>/dev/null | jq -r '.tag_name // empty')
  if [[ -z "$tag_name" ]]; then
    tag_name="v2.24.0"
  fi
  sudo curl -L "https://github.com/docker/compose/releases/download/${tag_name}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo -e "\n${GREEN}$(t "compose_installed")${NC}"
}

# Check script dependencies and offer to install missing (with consent)
check_dependencies() {
  local missing=() tool display_name confirm
  declare -A tool_names=(
    ["curl"]="curl"
    ["jq"]="jq"
    ["lz4"]="lz4"
    ["grep"]="grep"
    ["sed"]="sed"
    ["wget"]="wget"
    ["tar"]="tar"
    ["git"]="git"
    ["make"]="make"
    ["pv"]="pv"
    ["rsync"]="rsync"
  )

  echo -e "\n${BLUE}$(t "checking_deps")${NC}"

  for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      display_name=${tool_names[$tool]:-$tool}
      echo -e "${RED}❌ $display_name $(t "not_installed")${NC}"
      missing+=("$tool")
    else
      display_name=${tool_names[$tool]:-$tool}
      echo -e "${GREEN}✅ $display_name $(t "installed")${NC}"
    fi
  done

  if ! need_cmd docker; then
    echo -e "${RED}❌ Docker $(t "not_installed")${NC}"
    missing+=("docker")
  else
    echo -e "${GREEN}✅ Docker $(t "installed")${NC}"
  fi

  if ! docker compose version >/dev/null 2>&1 && ! need_cmd docker-compose; then
    echo -e "${RED}❌ Docker Compose $(t "not_installed")${NC}"
    missing+=("docker-compose")
  else
    echo -e "${GREEN}✅ Docker Compose $(t "installed")${NC}"
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "\n${YELLOW}$(t "missing_tools") ${missing[*]}${NC}"
    read -e -p "$(t "install_prompt")" confirm
    confirm=${confirm:-Y}

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      for tool in "${missing[@]}"; do
        case "$tool" in
          docker)
            install_docker
            ;;
          docker-compose)
            install_docker_compose
            ;;
          curl)
            echo -e "\n${CYAN}$(t "installing_curl")${NC}"
            if command -v apt-get &>/dev/null; then
              sudo apt-get update -qq && sudo apt-get install -y curl
            elif command -v yum &>/dev/null; then
              sudo yum install -y curl
            elif command -v brew &>/dev/null; then
              brew install curl
            else
              warn "Please install curl manually and run the script again."
            fi
            ;;
          jq)
            echo -e "\n${CYAN}$(t "installing_jq")${NC}"
            if command -v apt-get &>/dev/null; then
              sudo apt-get update -qq && sudo apt-get install -y jq
            elif command -v yum &>/dev/null; then
              sudo yum install -y jq
            elif command -v brew &>/dev/null; then
              brew install jq
            else
              warn "Please install jq manually and run the script again."
            fi
            ;;
          lz4)
            echo -e "\n${CYAN}$(t "installing_lz4")${NC}"
            if command -v apt-get &>/dev/null; then
              sudo apt-get update -qq && sudo apt-get install -y lz4
            elif command -v yum &>/dev/null; then
              sudo yum install -y lz4
            elif command -v brew &>/dev/null; then
              brew install lz4
            else
              warn "Please install lz4 manually and run the script again."
            fi
            ;;
          grep|sed)
            echo -e "\n${CYAN}$(t "installing_utils")${NC}"
            if command -v apt-get &>/dev/null; then
              sudo apt-get update -qq && sudo apt-get install -y grep sed
            elif command -v yum &>/dev/null; then
              sudo yum install -y grep sed
            elif command -v brew &>/dev/null; then
              brew install grep gnu-sed 2>/dev/null || brew install grep
            else
              warn "Please install grep/sed manually and run the script again."
            fi
            ;;
          wget)
            echo -e "\n${CYAN}$(t "installing_wget")${NC}"
            if command -v apt-get &>/dev/null; then
              sudo apt-get update -qq && sudo apt-get install -y wget
            elif command -v yum &>/dev/null; then
              sudo yum install -y wget
            elif command -v brew &>/dev/null; then
              brew install wget
            else
              warn "Please install wget manually and run the script again."
            fi
            ;;
          tar)
            echo -e "\n${CYAN}$(t "installing_tar")${NC}"
            if command -v apt-get &>/dev/null; then
              sudo apt-get update -qq && sudo apt-get install -y tar
            elif command -v yum &>/dev/null; then
              sudo yum install -y tar
            elif command -v brew &>/dev/null; then
              brew install gnu-tar 2>/dev/null || true
            else
              warn "Please install tar manually and run the script again."
            fi
            ;;
          git)
            echo -e "\n${CYAN}$(t "installing_git")${NC}"
            if command -v apt-get &>/dev/null; then
              sudo apt-get update -qq && sudo apt-get install -y git
            elif command -v yum &>/dev/null; then
              sudo yum install -y git
            elif command -v brew &>/dev/null; then
              brew install git
            else
              warn "Please install git manually and run the script again."
            fi
            ;;
          make)
            echo -e "\n${CYAN}$(t "installing_make")${NC}"
            if command -v apt-get &>/dev/null; then
              sudo apt-get update -qq && sudo apt-get install -y build-essential
            elif command -v yum &>/dev/null; then
              sudo yum groupinstall -y "Development Tools" 2>/dev/null || sudo yum install -y make gcc
            elif command -v brew &>/dev/null; then
              brew install make
            else
              warn "Please install make (build-essential) manually and run the script again."
            fi
            ;;
          pv)
            echo -e "\n${CYAN}$(t "installing_pv")${NC}"
            if command -v apt-get &>/dev/null; then
              sudo apt-get update -qq && sudo apt-get install -y pv
            elif command -v yum &>/dev/null; then
              sudo yum install -y pv
            elif command -v brew &>/dev/null; then
              brew install pv
            else
              warn "Please install pv manually and run the script again."
            fi
            ;;
          rsync)
            echo -e "\n${CYAN}$(t "installing_rsync")${NC}"
            if command -v apt-get &>/dev/null; then
              sudo apt-get update -qq && sudo apt-get install -y rsync
            elif command -v yum &>/dev/null; then
              sudo yum install -y rsync
            elif command -v brew &>/dev/null; then
              brew install rsync
            else
              warn "Please install rsync manually and run the script again."
            fi
            ;;
        esac
      done
    else
      echo -e "\n${RED}$(t "missing_required")${NC}"
      exit 1
    fi
  fi
}

# Optional: set WS_PORT, METRICS_PORT, CONSENSUS_PORT before calling to check them too
check_ports() {
  echo -e "\n${CYAN}$(t "checking_ports")${NC}"
  local ports_to_check="$HTTP_PORT $P2P_PORT ${WS_PORT:-} ${METRICS_PORT:-} ${CONSENSUS_PORT:-}"
  for port in $ports_to_check; do
    [[ -z "$port" ]] && continue
    if (command -v ss >/dev/null 2>&1 && ss -tuln 2>/dev/null | grep -q ":${port}\b") || \
       (command -v netstat >/dev/null 2>&1 && netstat -tuln 2>/dev/null | grep -q ":${port}\b"); then
      echo -e "  ${RED}$(t "port_busy") $port${NC}"
      return 1
    fi
    echo -e "  ${GREEN}$(t "port_free") $port${NC}"
  done
  return 0
}

# Get container status for display: "running", "stopped", or "none".
# Usage: container_display_status "container-name"
container_display_status() {
  local name="$1"
  if docker ps --format '{{.Names}}' 2>/dev/null | grep -q -w "$name"; then
    echo -e "${GREEN}\xE2\x9C\x85 $(t "status_running")${NC}"
  elif docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q -w "$name"; then
    echo -e "${YELLOW}\xE2\x8F\xB9 $(t "status_stopped")${NC}"
  else
    echo ""
  fi
}

# Select which node to operate on (snapshot, logs, stop, start, remove, etc.).
# Sets NODE_DIR, DATADIR, KEYDIR, CONTAINER_NAME, HTTP_PORT, P2P_PORT and returns 0.
# Returns 1 if no node installed or user cancelled.
select_node_for_operation() {
  local has_rpc=0 has_validator=0
  [[ -f "$TEMPO_HOME/rpc/docker-compose.yml" ]] && has_rpc=1
  [[ -f "$TEMPO_HOME/validator/docker-compose.yml" ]] && has_validator=1

  if [[ $has_rpc -eq 0 && $has_validator -eq 0 ]]; then
    printf "${RED}$(t "node_not_installed_any")${NC}\n" "$TEMPO_HOME"
    return 1
  fi

  local choice=""
  if [[ $((has_rpc + has_validator)) -eq 1 ]]; then
    if [[ $has_rpc -eq 1 ]]; then choice="1"; fi
    if [[ $has_validator -eq 1 ]]; then choice="2"; fi
  else
    echo -e "\n${CYAN}$(t "select_node_which")${NC}"
    if [[ $has_rpc -eq 1 ]]; then
      printf "  ${GREEN}$(t "select_node_rpc")${NC} %b\n" "$TEMPO_HOME" "$(container_display_status "tempo-rpc")"
    fi
    if [[ $has_validator -eq 1 ]]; then
      printf "  ${GREEN}$(t "select_node_validator")${NC} %b\n" "$TEMPO_HOME" "$(container_display_status "tempo-validator")"
    fi
    echo -e "  ${YELLOW}$(t "select_node_cancel")${NC}"
    read -e -p "$(t "choose_option") " choice
    choice=$(printf '%s' "$choice" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  fi

  case "$choice" in
    1)
      NODE_DIR="$TEMPO_HOME/rpc"
      DATADIR="$NODE_DIR/data"
      KEYDIR="$NODE_DIR/keys"
      CONTAINER_NAME="tempo-rpc"
      HTTP_PORT="${RPC_HTTP_PORT:-8545}"
      P2P_PORT="${RPC_P2P_PORT:-30303}"
      ;;
    2)
      NODE_DIR="$TEMPO_HOME/validator"
      DATADIR="$NODE_DIR/data"
      KEYDIR="$NODE_DIR/keys"
      CONTAINER_NAME="tempo-validator"
      HTTP_PORT="${VALIDATOR_HTTP_PORT:-8545}"
      P2P_PORT="${VALIDATOR_P2P_PORT:-30303}"
      ;;
    0|"")
      return 1
      ;;
    *)
      if [[ $((has_rpc + has_validator)) -gt 1 ]]; then
        echo -e "\n${RED}$(t "invalid_choice")${NC}"
        return 1
      fi
      ;;
  esac
  return 0
}

# Resolve image to use (latest or TEMPO_IMAGE). Prints only the image name to stdout.
resolve_tempo_image() {
  local image_to_use="$TEMPO_IMAGE"
  if [[ "$TEMPO_IMAGE" == "ghcr.io/tempoxyz/tempo:1.1.4" ]]; then
    info "Checking for latest Tempo version..." >&2
    local latest_version=$(get_latest_tempo_version 2>/dev/null)
    if [[ -n "$latest_version" && "$latest_version" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      local latest_normalized="${latest_version#v}"
      image_to_use="ghcr.io/tempoxyz/tempo:${latest_normalized}"
      info "Using latest version: $latest_version" >&2
    else
      warn "Could not fetch latest version, using default: $TEMPO_IMAGE" >&2
    fi
  fi
  echo "$image_to_use"
}

# Install Tempo RPC Node (Docker). No validator key; uses --follow.
# Installs into TEMPO_HOME/rpc (new layout).
# https://docs.tempo.xyz/guide/node/rpc
install_tempo_rpc() {
  check_docker
  local rpc_http_port="${RPC_HTTP_PORT:-8545}"
  local rpc_ws_port="${RPC_WS_PORT:-8546}"
  local rpc_p2p_port="${RPC_P2P_PORT:-30303}"
  local rpc_discovery_port="${RPC_DISCOVERY_PORT:-30303}"
  local rpc_metrics_port="${RPC_METRICS_PORT:-9000}"
  HTTP_PORT=$rpc_http_port
  P2P_PORT=$rpc_p2p_port
  WS_PORT=$rpc_ws_port
  METRICS_PORT=$rpc_metrics_port
  CONSENSUS_PORT=
  if ! check_ports; then
    warn "Change RPC_HTTP_PORT/RPC_WS_PORT/RPC_P2P_PORT/RPC_METRICS_PORT (or free ports) and run again."
    return 1
  fi

  echo -e "\n${CYAN}$(t "rpc_node_info")${NC}"
  local image_to_use
  image_to_use=$(resolve_tempo_image)

  info "$(t "pulling_image")"
  if ! docker pull "$image_to_use"; then
    error "Failed to pull Docker image: $image_to_use"
  fi

  NODE_DIR="$TEMPO_HOME/rpc"
  DATADIR="$NODE_DIR/data"
  KEYDIR="$NODE_DIR/keys"
  CONTAINER_NAME="tempo-rpc"
  HTTP_PORT=$rpc_http_port
  P2P_PORT=$rpc_p2p_port

  info "$(t "creating_dirs")"
  mkdir -p "$DATADIR"
  mkdir -p "$KEYDIR"

  info "$(t "creating_compose")"
  mkdir -p "$NODE_DIR"
  echo "rpc" > "$NODE_DIR/.node_type"
  cat > "$NODE_DIR/docker-compose.yml" <<EOF
services:
  tempo:
    image: ${image_to_use}
    container_name: ${CONTAINER_NAME}
    restart: unless-stopped
    command: >
      node --datadir /data
      --chain ${CHAIN}
      --follow
      --http --http.addr ${HTTP_ADDR} --http.port ${rpc_http_port}
      --http.api eth,net,web3,txpool,trace
      --port ${rpc_p2p_port}
      --discovery.addr ${DISCOVERY_ADDR} --discovery.port ${rpc_discovery_port}
      --metrics ${rpc_metrics_port}
    ports:
      - "${rpc_http_port}:${rpc_http_port}"
      - "${rpc_ws_port}:${rpc_ws_port}"
      - "${rpc_p2p_port}:${rpc_p2p_port}/tcp"
      - "${rpc_p2p_port}:${rpc_p2p_port}/udp"
      - "${rpc_metrics_port}:${rpc_metrics_port}"
    volumes:
      - ${DATADIR}:/data
    environment:
      - RUST_LOG=info
EOF

  ensure_env_tempo_template || true

  info "$(t "starting_node")"
  (cd "$NODE_DIR" && $(docker_compose_cmd) up -d)

  echo ""
  info "$(t "install_done")"
  printf "$(t "rpc_info")\n" "$HTTP_ADDR" "$HTTP_PORT"
  printf "$(t "p2p_info")\n" "$P2P_PORT"
  echo -e "\nLogs: docker logs -f $CONTAINER_NAME"
}

# Install Tempo Validator Node (Docker). Requires signing key and fee recipient.
# Installs into TEMPO_HOME/validator (new layout).
# https://docs.tempo.xyz/guide/node/validator
install_tempo_validator() {
  check_docker
  local val_http_port="${VALIDATOR_HTTP_PORT:-8545}"
  local val_ws_port="${VALIDATOR_WS_PORT:-8546}"
  local val_p2p_port="${VALIDATOR_P2P_PORT:-30303}"
  local val_consensus_port="${VALIDATOR_CONSENSUS_PORT:-8000}"
  local val_discovery_port="${VALIDATOR_DISCOVERY_PORT:-30303}"
  local val_metrics_port="${VALIDATOR_METRICS_PORT:-9000}"
  HTTP_PORT=$val_http_port
  P2P_PORT=$val_p2p_port
  WS_PORT=$val_ws_port
  METRICS_PORT=$val_metrics_port
  CONSENSUS_PORT=$val_consensus_port
  if ! check_ports; then
    warn "Change VALIDATOR_HTTP_PORT/VALIDATOR_WS_PORT/VALIDATOR_P2P_PORT/VALIDATOR_CONSENSUS_PORT/VALIDATOR_METRICS_PORT (or free ports) and run again."
    return 1
  fi

  echo -e "\n${CYAN}$(t "validator_node_info")${NC}"
  read -e -p "$(t "enter_fee_recipient")" FEE_RECIPIENT
  FEE_RECIPIENT=$(echo "$FEE_RECIPIENT" | tr -d ' ')
  if [[ -z "$FEE_RECIPIENT" || ! "$FEE_RECIPIENT" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
    error "$(t "fee_recipient_required")"
  fi

  local image_to_use
  image_to_use=$(resolve_tempo_image)

  info "$(t "pulling_image")"
  if ! docker pull "$image_to_use"; then
    error "Failed to pull Docker image: $image_to_use"
  fi

  NODE_DIR="$TEMPO_HOME/validator"
  DATADIR="$NODE_DIR/data"
  KEYDIR="$NODE_DIR/keys"
  CONTAINER_NAME="tempo-validator"
  HTTP_PORT=$val_http_port
  P2P_PORT=$val_p2p_port

  info "$(t "creating_dirs")"
  mkdir -p "$DATADIR" "$KEYDIR"

  if [[ ! -f "$KEYDIR/signing.key" ]]; then
    info "$(t "generating_key")"
    docker run --rm -v "$KEYDIR:/keys" "$image_to_use" consensus generate-private-key --output /keys/signing.key
  else
    warn "$(t "key_exists")"
  fi

  info "$(t "creating_compose")"
  mkdir -p "$NODE_DIR"
  echo "validator" > "$NODE_DIR/.node_type"
  cat > "$NODE_DIR/docker-compose.yml" <<EOF
services:
  tempo:
    image: ${image_to_use}
    container_name: ${CONTAINER_NAME}
    restart: unless-stopped
    command: >
      node --datadir /data
      --chain ${CHAIN}
      --port ${val_p2p_port}
      --discovery.addr ${DISCOVERY_ADDR} --discovery.port ${val_discovery_port}
      --http --http.addr ${HTTP_ADDR} --http.port ${val_http_port}
      --http.api eth,net,web3,txpool,trace
      --consensus.signing-key /keys/signing.key
      --consensus.fee-recipient ${FEE_RECIPIENT}
      --metrics ${val_metrics_port}
    ports:
      - "${val_http_port}:${val_http_port}"
      - "${val_ws_port}:${val_ws_port}"
      - "${val_p2p_port}:${val_p2p_port}/tcp"
      - "${val_p2p_port}:${val_p2p_port}/udp"
      - "${val_consensus_port}:${val_consensus_port}"
      - "${val_metrics_port}:${val_metrics_port}"
    volumes:
      - ${DATADIR}:/data
      - ${KEYDIR}:/keys
    environment:
      - RUST_LOG=info
EOF

  ensure_env_tempo_template || true

  info "$(t "starting_node")"
  (cd "$NODE_DIR" && $(docker_compose_cmd) up -d)

  echo ""
  info "$(t "install_done")"
  printf "$(t "rpc_info")\n" "$HTTP_ADDR" "$HTTP_PORT"
  printf "$(t "p2p_info")\n" "$P2P_PORT"
  echo -e "\nLogs: docker logs -f $CONTAINER_NAME"
}

# Fetch all tags from Docker Hub (https://hub.docker.com/r/tempoxyz/tempo/) with pagination.
# Filter to X.Y.Z only (e.g. 1.1.11, 1.1.1). Output one tag per line.
# Do not return non-zero so that set -e does not exit the script.
fetch_all_semver_tags() {
  local all_raw=""
  local page=1
  local page_tags
  if ! command -v jq >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
    echo ""
    return
  fi
  while true; do
    page_tags=$(curl -sL --connect-timeout 10 --max-time 30 "https://hub.docker.com/v2/repositories/tempoxyz/tempo/tags/?page=${page}&page_size=100" 2>/dev/null | jq -r '.results[].name' 2>/dev/null)
    [[ -z "$page_tags" ]] && break
    all_raw="${all_raw}${all_raw:+$'\n'}${page_tags}"
    page=$((page + 1))
    [[ $page -gt 10 ]] && break
  done
  if [[ -z "$all_raw" ]]; then
    echo ""
    return
  fi
  # Only X.Y.Z or vX.Y.Z (e.g. 1.1.11, 1.1.1); exclude pre-release suffixes
  echo "$all_raw" | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | sed 's/^v//' | sort -V 2>/dev/null | uniq
}

downgrade_tempo() {
  echo -e "\n${GREEN}=== $(t "downgrade_title") ===${NC}"
  select_node_for_operation || return 1
  if [[ ! -f "$NODE_DIR/docker-compose.yml" ]]; then
    printf "${RED}$(t "node_not_installed")${NC}\n" "$NODE_DIR"
    return 1
  fi

  echo -e "${YELLOW}$(t "downgrade_fetching")${NC}"
  # Known tags for Moderato (GHCR); user can extend
  TAGS="1.1.4 1.1.0 1.0.0"
  echo "  0) $(t "downgrade_show_all")"
  i=1
  for tag in $TAGS; do
    echo "  $i) $tag"
    i=$((i+1))
  done
  echo "  $i) Enter custom tag"
  read -e -p "$(t "downgrade_available") " num

  TAG=""
  if [[ "$num" == "0" ]]; then
    # Must not let fetch return code trigger set -e exit
    all_tags=$(fetch_all_semver_tags) || true
    all_tags=$(echo "$all_tags" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | uniq)
    if [[ -z "$all_tags" ]]; then
      echo -e "${YELLOW}$(t "downgrade_fetch_error")${NC}"
      echo ""
      j=1
      for tag in $TAGS; do
        echo "  $j) $tag"
        j=$((j+1))
      done
      echo "  $j) Enter custom tag"
      read -e -p "$(t "downgrade_available") " num
      k=1
      for tag in $TAGS; do
        if [[ "$num" == "$k" ]]; then TAG="$tag"; break; fi
        k=$((k+1))
      done
      if [[ "$num" == "$j" ]]; then
        read -e -p "Tag (e.g. 1.1.0): " TAG
      fi
    else
      # Numbered list + read (works without TTY / select)
      echo -e "\n${CYAN}$(t "downgrade_available")${NC}"
      n=1
      while IFS= read -r ver; do
        [[ -z "$ver" ]] && continue
        echo "  $n) $ver"
        n=$((n + 1))
      done <<< "$all_tags"
      choice=""
      while true; do
        read -e -p "#? " choice
        n=1
        while IFS= read -r ver; do
          [[ -z "$ver" ]] && continue
          if [[ "$choice" == "$n" ]]; then TAG="$ver"; break 2; fi
          n=$((n + 1))
        done <<< "$all_tags"
        echo -e "${RED}$(t "downgrade_invalid_choice")${NC}"
      done
    fi
  else
    k=1
    for tag in $TAGS; do
      if [[ "$num" == "$k" ]]; then TAG="$tag"; break; fi
      k=$((k+1))
    done
    if [[ "$num" == "$i" ]]; then
      read -e -p "Tag (e.g. 1.1.0): " TAG
    fi
  fi

  if [[ -z "$TAG" ]]; then
    echo -e "${RED}$(t "downgrade_invalid_choice")${NC}"
    return 1
  fi
  # Normalize v1.1.0 -> 1.1.0
  TAG="${TAG#v}"
  # Allow only X.Y.Z format for safety
  if [[ ! "$TAG" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}$(t "downgrade_invalid_choice")${NC}"
    return 1
  fi

  echo -e "\n${YELLOW}$(t "downgrade_selected") $TAG${NC}"
  DOCKER_HUB_IMAGE="tempoxyz/tempo"
  echo -e "${YELLOW}$(t "downgrade_pulling") $DOCKER_HUB_IMAGE:$TAG...${NC}"
  if ! docker pull "$DOCKER_HUB_IMAGE:$TAG"; then
    echo -e "${RED}$(t "downgrade_pull_error")${NC}"
    return 1
  fi
  data_dir="${DATADIR:-$NODE_DIR/data}"
  if [[ ! -d "$data_dir" ]]; then
    mkdir -p "$data_dir"
  fi
  downgrade_img="$DOCKER_HUB_IMAGE:$TAG"
  chain_id=$(chain_to_chain_id "$CHAIN")
  snapshot_url=$(get_snapshot_url_from_api "ghcr.io/tempoxyz/tempo:$TAG" "$chain_id")

  echo -e "${YELLOW}$(t "downgrade_stopping")${NC}"
  (cd "$NODE_DIR" && $(docker_compose_cmd) down) || true
  printf "$(t "downgrade_downloading_snapshot")\n" "$CHAIN"
  # API stores image as ghcr.io/tempoxyz/tempo:TAG — query by that so snapshot version matches node version
  run_snapshot_download_with_retry "$downgrade_img" "$data_dir" "$snapshot_url" "$CHAIN"

  echo -e "${YELLOW}$(t "downgrade_updating")${NC}"
  sed -i.bak "s|image:.*tempo:[^[:space:]]*|image: $DOCKER_HUB_IMAGE:$TAG|" "$NODE_DIR/docker-compose.yml"
  echo -e "${YELLOW}$(t "downgrade_starting") $TAG...${NC}"
  (cd "$NODE_DIR" && $(docker_compose_cmd) up -d)
  echo -e "${GREEN}$(t "downgrade_success") $TAG${NC}"
  send_telegram "Tempo downgrade: done. Node ${TAG} started. Chain: ${CHAIN}"
}

show_version() {
  echo -e "\n${CYAN}$(t "version_title")${NC}"
  select_node_for_operation || return 1
  cid=$(docker ps -q -f name="$CONTAINER_NAME" 2>/dev/null | head -1)
  if [[ -z "$cid" ]]; then
    echo -e "${RED}$(t "container_not_found")${NC}"
    return
  fi
  echo -e "${GREEN}$(t "container_found")${NC} $cid"
  ver=$(docker exec "$cid" tempo --version 2>/dev/null || true)
  if [[ -n "$ver" ]]; then
    echo -e "${GREEN}$(t "node_version")${NC} $ver"
  else
    # Fallback: show image tag from compose
    if [[ -f "$NODE_DIR/docker-compose.yml" ]]; then
      img=$(grep -E '^\s+image:' "$NODE_DIR/docker-compose.yml" | sed 's/.*tempo:\(.*\)/\1/' | tr -d ' ')
      echo -e "${GREEN}Image tag:${NC} $img"
    else
      echo -e "${RED}$(t "version_failed")${NC}"
    fi
  fi
}

view_logs() {
  echo -e "\n${CYAN}$(t "view_logs")${NC}"
  select_node_for_operation || return 1
  cid=$(docker ps -q -f name="$CONTAINER_NAME" 2>/dev/null | head -1)
  if [[ -z "$cid" ]]; then
    echo -e "${RED}$(t "container_not_found")${NC}"
    return
  fi
  echo -e "${GREEN}$(t "container_found")${NC} $cid"
  echo -e "${BLUE}$(t "press_ctrlc")${NC}\n"
  # Run docker logs in background; trap SIGINT in this process so Ctrl+C kills logs and returns to menu
  docker logs --tail 500 -f "$cid" &
  local logpid=$!
  trap "kill $logpid 2>/dev/null; echo -e '\n${YELLOW}$(t "return_menu")${NC}'; trap - SIGINT; return 0" SIGINT
  wait $logpid 2>/dev/null
  trap - SIGINT
  echo -e "\n${YELLOW}$(t "return_menu")${NC}"
}

# Snapshot menu: list snapshots from API, choose version or enter URL, download, optionally restart node.
# https://docs.tempo.xyz/guide/node/rpc#manually-downloading-snapshots
snapshot_menu() {
  echo -e "\n${CYAN}$(t "snapshot_title")${NC}"
  select_node_for_operation || return 1
  if [[ ! -f "$NODE_DIR/docker-compose.yml" ]]; then
    echo -e "${RED}$(t "snapshot_no_compose")${NC}"
    return 1
  fi

  local data_dir="${DATADIR:-$NODE_DIR/data}"
  local img
  img=$(grep -E '^\s+image:' "$NODE_DIR/docker-compose.yml" | head -1 | sed 's/.*image:[[:space:]]*//' | tr -d ' ')
  [[ -z "$img" ]] && img="${TEMPO_IMAGE:-ghcr.io/tempoxyz/tempo:1.1.4}"
  local chain_id
  chain_id=$(chain_to_chain_id "$CHAIN")
  if [[ -z "$chain_id" ]]; then
    warn "Unknown chain: $CHAIN. Set CHAIN=moderato or chainId."
    return 1
  fi

  printf "$(t "snapshot_list")\n\n" "$CHAIN" "$chain_id"
  local list
  list=$(list_snapshots_from_api "$chain_id" "$img")
  if [[ -z "$list" ]]; then
    list=$(list_snapshots_from_api "$chain_id" "")
  fi

  local idx=0
  local urls=()
  local dates=()
  local blocks=()
  while IFS='|' read -r date block url image; do
    [[ -z "$url" ]] && continue
    idx=$((idx + 1))
    urls+=("$url")
    dates+=("$date")
    blocks+=("$block")
    echo "  $idx) $date  block $block  (image: $image)"
  done <<< "$list"

  if [[ $idx -eq 0 ]]; then
    warn "No snapshots found for chainId $chain_id. You can enter URL manually."
  fi

  echo "  0) $(t "snapshot_latest")"
  echo "  u) $(t "snapshot_enter_url")"
  echo "  e) $(t "snapshot_extract_local")"
  read -e -p "$(t "snapshot_choice")" choice
  choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

  local snapshot_url=""
  if [[ "$choice" == "e" ]]; then
    read -e -p "Path to .tar.lz4 file: " local_archive
    local_archive=$(echo "$local_archive" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ -z "$local_archive" || ! -f "$local_archive" ]]; then
      echo -e "${YELLOW}$(t "remove_cancelled")${NC}"
      return 0
    fi
    local lz4_cmd
    if lz4_supports_threading; then
      lz4_cmd="lz4 -d -T0"
    else
      warn "$(t "lz4_no_threading")"
      read -e -p "$(t "lz4_update_ask")" lz4_yn
      if [[ "$lz4_yn" =~ ^[yY] ]]; then
        if install_lz4_from_source && lz4_supports_threading; then
          lz4_cmd="lz4 -d -T0"
        else
          lz4_cmd="lz4 -d"
        fi
      else
        lz4_cmd="lz4 -d"
      fi
    fi
    echo -e "${YELLOW}$(t "snapshot_downloading")${NC}"
    (cd "$NODE_DIR" && $(docker_compose_cmd) down) || true
    info "Removing old data and extracting snapshot into $data_dir..."
    rm -rf "${data_dir:?}"
    mkdir -p "$data_dir"
    if ! snapshot_extract_with_progress "$local_archive" "$data_dir" "$lz4_cmd"; then
      error "Extraction failed."
    fi
    info "$(t "snapshot_done")"
    echo -e "${YELLOW}$(t "snapshot_restarting")${NC}"
    (cd "$NODE_DIR" && $(docker_compose_cmd) up -d)
    info "$(t "install_done")"
    send_telegram "Tempo snapshot: done. Node restarted. Chain: ${CHAIN}"
    return 0
  elif [[ "$choice" == "u" ]]; then
    read -e -p "URL: " snapshot_url
    snapshot_url=$(echo "$snapshot_url" | tr -d ' ')
    if [[ -z "$snapshot_url" ]]; then
      echo -e "${YELLOW}$(t "remove_cancelled")${NC}"
      return 0
    fi
  elif [[ "$choice" == "0" || -z "$choice" ]]; then
    if [[ $idx -gt 0 ]]; then
      snapshot_url="${urls[0]}"
      info "Using latest: ${dates[0]} block ${blocks[0]}"
    else
      # Fallback to API by image+chainId
      snapshot_url=$(get_snapshot_url_from_api "$img" "$chain_id")
    fi
  else
    if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le $idx ]]; then
      snapshot_url="${urls[$((choice - 1))]}"
    else
      echo -e "${YELLOW}$(t "remove_cancelled")${NC}"
      return 0
    fi
  fi

  if [[ -z "$snapshot_url" ]]; then
    error "Could not resolve snapshot URL. Try option 'u' and paste URL from https://snapshots.tempoxyz.dev"
  fi

  echo -e "${YELLOW}$(t "snapshot_downloading")${NC}"
  # Stop node first (so sync does not slow down download), then download, remove data_dir, extract into data_dir, restart
  (cd "$NODE_DIR" && $(docker_compose_cmd) down) || true
  run_snapshot_download_with_retry "$img" "$data_dir" "$snapshot_url" "$CHAIN"

  info "$(t "snapshot_done")"
  echo -e "${YELLOW}$(t "snapshot_restarting")${NC}"
  (cd "$NODE_DIR" && $(docker_compose_cmd) up -d)
  info "$(t "install_done")"
  send_telegram "Tempo snapshot: done. Node restarted. Chain: ${CHAIN}"
}

check_disk_usage() {
  select_node_for_operation || return 1
  if [[ ! -f "$NODE_DIR/docker-compose.yml" ]]; then
    printf "${RED}$(t "node_not_installed")${NC}\n" "$NODE_DIR"
    return 1
  fi
  echo -e "\n${CYAN}$(t "disk_usage")${NC}"
  local data_dir="${DATADIR:-$NODE_DIR/data}"
  local key_dir="${KEYDIR:-$NODE_DIR/keys}"
  if docker ps -q -f name="$CONTAINER_NAME" 2>/dev/null | head -1 | grep -q .; then
    printf "$(t "disk_usage_data") " "$CONTAINER_NAME"
    docker exec "$CONTAINER_NAME" du -sh /data 2>/dev/null || echo "—"
    if [[ -d "$key_dir" ]] && docker exec "$CONTAINER_NAME" test -d /keys 2>/dev/null; then
      printf "$(t "disk_usage_keys") " "$CONTAINER_NAME"
      docker exec "$CONTAINER_NAME" du -sh /keys 2>/dev/null || echo "—"
    fi
  else
    echo -e "${YELLOW}$(t "disk_usage_container_off")${NC}"
    printf "$(t "disk_usage_data") " "$CONTAINER_NAME"
    if [[ -d "$data_dir" ]]; then
      du -sh "$data_dir" 2>/dev/null || echo "—"
    else
      echo "(path not found: $data_dir)"
    fi
    if [[ -d "$key_dir" ]]; then
      printf "$(t "disk_usage_keys") " "$CONTAINER_NAME"
      du -sh "$key_dir" 2>/dev/null || echo "—"
    fi
  fi
}

remove_tempo() {
  echo -e "\n${CYAN}$(t "remove_title")${NC}"
  select_node_for_operation || return 1
  if [[ ! -f "$NODE_DIR/docker-compose.yml" ]]; then
    printf "${RED}$(t "remove_not_installed")${NC}\n" "$NODE_DIR"
    return 1
  fi
  echo "$(t "remove_option_container")"
  echo "$(t "remove_option_full")"
  read -e -p "$(t "remove_choose")" mode
  if [[ "$mode" != "1" && "$mode" != "2" ]]; then
    echo -e "${YELLOW}$(t "remove_cancelled")${NC}"
    return 0
  fi
  if [[ "$mode" == "1" ]]; then
    read -e -p "$(t "remove_confirm_container")" confirm
  else
    read -e -p "$(t "remove_confirm_full")" confirm
  fi
  if [[ "$confirm" != "yes" ]]; then
    echo -e "${YELLOW}$(t "remove_cancelled")${NC}"
    return 0
  fi
  echo -e "${YELLOW}$(t "remove_stopping")${NC}"
  (cd "$NODE_DIR" && $(docker_compose_cmd) down) || true
  if [[ "$mode" == "2" ]]; then
    echo -e "${YELLOW}$(t "remove_deleting")${NC}"
    rm -rf "${NODE_DIR:?}"
    echo -e "${GREEN}$(t "remove_done")${NC}"
  else
    printf "${GREEN}$(t "remove_done_kept")\n" "$NODE_DIR"
  fi
}

stop_container() {
  select_node_for_operation || return 1
  if [[ ! -f "$NODE_DIR/docker-compose.yml" ]]; then
    printf "${RED}$(t "node_not_installed")${NC}\n" "$NODE_DIR"
    return 1
  fi
  echo -e "\n${CYAN}$(t "option_stop")${NC}"
  (cd "$NODE_DIR" && $(docker_compose_cmd) down) || true
  echo -e "${GREEN}$(t "stop_done")${NC}"
}

start_container() {
  select_node_for_operation || return 1
  if [[ ! -f "$NODE_DIR/docker-compose.yml" ]]; then
    printf "${RED}$(t "node_not_installed")${NC}\n" "$NODE_DIR"
    return 1
  fi
  echo -e "\n${CYAN}$(t "option_start")${NC}"
  (cd "$NODE_DIR" && $(docker_compose_cmd) up -d)
  echo -e "${GREEN}$(t "start_done")${NC}"
}

check_sync_blocks() {
  select_node_for_operation || return 1
  if [[ ! -f "$NODE_DIR/docker-compose.yml" ]]; then
    echo -e "\n${RED}$(t "check_sync_no_compose")${NC}"
    return 1
  fi
  local rpc_url="http://${HTTP_ADDR:-0.0.0.0}:${HTTP_PORT:-8545}"
  if ! command -v cast &>/dev/null; then
    echo -e "\n${YELLOW}$(t "check_sync_cast_required")${NC}"
    return 1
  fi
  while true; do
    echo ""
    printf "${CYAN}$(t "check_sync_menu_title")${NC}\n" "$rpc_url"
    echo -e "${GREEN}$(t "check_sync_sub_peers")${NC}"
    echo -e "${GREEN}$(t "check_sync_sub_block_number")${NC}"
    echo -e "${GREEN}$(t "check_sync_sub_block")${NC}"
    echo -e "${GREEN}$(t "check_sync_sub_sync_status")${NC}"
    echo -e "${YELLOW}$(t "check_sync_back")${NC}"
    echo -e "${BLUE}--------------------------------${NC}"
    read -e -p "$(t "choose_option") " sub
    case "$sub" in
      1)
        echo ""
        echo -e "${GREEN}$(t "check_sync_peers")${NC}"
        peer_hex=$(cast rpc net_peerCount --rpc-url "$rpc_url" 2>/dev/null) || true
        if [[ -z "$peer_hex" ]]; then
          printf "${RED}$(t "check_sync_rpc_failed")${NC}\n" "$rpc_url"
        else
          peer_dec=$(printf "%d" "$peer_hex" 2>/dev/null || echo "?")
          echo "  $peer_dec"
        fi
        ;;
      2)
        echo ""
        echo -e "${GREEN}$(t "check_sync_block_height")${NC}"
        if ! cast block-number --rpc-url "$rpc_url" 2>/dev/null; then
          printf "${RED}$(t "check_sync_rpc_failed")${NC}\n" "$rpc_url"
        fi
        ;;
      3)
        echo ""
        echo -e "${GREEN}$(t "check_sync_block_info")${NC}"
        cast block --rpc-url "$rpc_url" 2>/dev/null || printf "${RED}$(t "check_sync_rpc_failed")${NC}\n" "$rpc_url"
        ;;
      4)
        echo ""
        echo -e "${CYAN}$(t "sync_status_title")${NC}"
        local local_rpc="http://127.0.0.1:${HTTP_PORT:-8545}"
        local resp
        resp=$(curl -s "$local_rpc" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' 2>/dev/null)
        if [[ -z "$resp" ]]; then
          echo -e "${RED}$(t "sync_status_rpc_failed")${NC}"
        elif echo "$resp" | jq -e '.result == false' >/dev/null 2>&1; then
          echo -e "${GREEN}$(t "sync_status_synced")${NC}"
        elif echo "$resp" | jq -e '.result' >/dev/null 2>&1; then
          echo -e "${YELLOW}$(t "sync_status_syncing")${NC}"
          local start_hex current_hex highest_hex
          start_hex=$(echo "$resp" | jq -r '.result.startingBlock // empty')
          current_hex=$(echo "$resp" | jq -r '.result.currentBlock // empty')
          highest_hex=$(echo "$resp" | jq -r '.result.highestBlock // empty')
          local start_dec current_dec highest_dec
          start_dec=$(printf "%d" "$start_hex")
          current_dec=$(printf "%d" "$current_hex")
          highest_dec=$(printf "%d" "$highest_hex")
          printf "  $(t "sync_status_blocks")\n" "$start_dec" "$current_dec" "$highest_dec"
          if [[ -n "$highest_dec" && "$highest_dec" -gt 0 ]]; then
            local pct=$((100 * current_dec / highest_dec))
            printf "  $(t "sync_status_progress")\n" "$pct"
          fi
          if command -v cast &>/dev/null; then
            local network_block
            network_block=$(cast block-number --rpc-url "https://rpc.moderato.tempo.xyz" 2>/dev/null)
            if [[ -n "$network_block" ]]; then
              printf "  $(t "sync_status_network")\n" "$network_block"
              local lag=$((network_block - highest_dec))
              if [[ $lag -gt 0 ]]; then
                printf "  $(t "sync_status_lag")\n" "$lag"
              fi
            fi
          fi
          local warp_a warp_p
          warp_a=$(echo "$resp" | jq -r '.result.warpChunksAmount // empty')
          warp_p=$(echo "$resp" | jq -r '.result.warpChunksProcessed // empty')
          if [[ -n "$warp_a" && "$warp_a" != "null" && -n "$warp_p" && "$warp_p" != "null" ]]; then
            printf "  $(t "sync_status_warp")\n" "$warp_p" "$warp_a"
          fi
          echo ""
          echo -e "${CYAN}$(t "sync_status_stages")${NC}"
          echo "$resp" | jq -r '.result.stages[]? | "\(.name): \(.block)"' 2>/dev/null | while IFS=: read -r name block_hex; do
            name=$(echo "$name" | sed 's/^ *//;s/ *$//')
            block_hex=$(echo "$block_hex" | sed 's/^ *//;s/ *$//')
            [[ -z "$block_hex" ]] && continue
            block_dec=$(printf "%d" "$block_hex" 2>/dev/null || echo "?")
            printf "  %-24s %s (%s)\n" "$name" "$block_hex" "$block_dec"
          done
        else
          echo -e "${RED}$(t "sync_status_rpc_failed")${NC}"
        fi
        ;;
      0) return 0 ;;
      *) echo -e "\n${RED}$(t "invalid_choice")${NC}" ;;
    esac
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
  done
}

update_installer_script() {
  echo -e "\n${CYAN}$(t "update_installer_title")${NC}"
  if [[ -z "${SCRIPT_URL:-}" ]]; then
    echo -e "${RED}$(t "update_installer_no_url")${NC}"
    return 1
  fi

  update_installer
}

check_for_updates() {
  echo -e "\n${CYAN}$(t "check_updates_title")${NC}"
  
  # Check installer version
  printf "${GREEN}$(t "installer_version")\n" "$INSTALLER_VERSION"
  if [[ -n "${SCRIPT_URL:-}" ]]; then
    check_installer_up_to_date
  fi
  
  # Check Tempo version
  echo ""
  local latest_version=$(get_latest_tempo_version 2>/dev/null)
  if [[ -n "$latest_version" && "$latest_version" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf "${GREEN}$(t "check_updates_latest")\n" "$latest_version"
    
    # Get current installed version (any node: rpc or validator)
    local current_version=""
    if select_node_for_operation 2>/dev/null && [[ -f "$NODE_DIR/docker-compose.yml" ]]; then
      local img=$(grep -E '^\s+image:' "$NODE_DIR/docker-compose.yml" | head -1 | sed 's/.*tempo:\(.*\)/\1/' | tr -d ' ')
      if [[ -n "$img" ]]; then
        current_version="$img"
        printf "${GREEN}$(t "check_updates_current")\n" "$current_version"
        
        # Normalize versions for comparison
        local latest_normalized="${latest_version#v}"
        local current_normalized="${current_version#v}"
        
        if version_gt "$latest_normalized" "$current_normalized"; then
          echo -e "${YELLOW}$(t "check_updates_newer")${NC}"
          echo -e "${CYAN}Run option 4 (Downgrade node version) to update to $latest_version${NC}"
        else
          echo -e "${GREEN}$(t "check_updates_current_latest")${NC}"
        fi
      fi
    else
      echo -e "${YELLOW}Tempo node not installed.${NC}"
    fi
  else
    echo -e "${YELLOW}Could not fetch latest Tempo version.${NC}"
  fi
}

main_menu() {
  while true; do
    echo -e "\n${BLUE}$(t "title")${NC}"
    echo -e "${GREEN}$(t "option1")${NC}"
    echo -e "${GREEN}$(t "option1b")${NC}"
    echo -e "${CYAN}$(t "option_snap")${NC}"
    echo -e "${YELLOW}$(t "option2")${NC}"
    echo -e "${CYAN}$(t "option3")${NC}"
    echo -e "${CYAN}$(t "option4")${NC}"
    echo -e "${RED}$(t "option6")${NC}"
    echo -e "${CYAN}$(t "option8")${NC}"
    echo -e "${CYAN}$(t "option_stop")${NC}"
    echo -e "${CYAN}$(t "option_start")${NC}"
    echo -e "${CYAN}$(t "option_check_sync")${NC}"
    echo -e "${CYAN}$(t "option_disk")${NC}"
    echo -e "${RED}$(t "option0")${NC}"
    echo -e "${BLUE}================================${NC}"
    read -e -p "$(t "choose_option") " choice
    command_executed=false
    case "$choice" in
      1) install_tempo_rpc; command_executed=true ;;
      2) install_tempo_validator; command_executed=true ;;
      3) snapshot_menu; command_executed=true ;;
      4) (downgrade_tempo && command_executed=true) || true ;;
      5) show_version; command_executed=true ;;
      6) (view_logs && command_executed=true) || true ;;
      7) (remove_tempo && command_executed=true) || true ;;
      8) check_for_updates; command_executed=true ;;
      9) (stop_container && command_executed=true) || true ;;
      10) (start_container && command_executed=true) || true ;;
      11) (check_sync_blocks && command_executed=true) || true ;;
      12) (check_disk_usage && command_executed=true) || true ;;
      0) echo -e "\n${GREEN}$(t "goodbye")${NC}"; exit 0 ;;
      *) echo -e "\n${RED}$(t "invalid_choice")${NC}" ;;
    esac
    if [[ "$command_executed" == true ]]; then
      # Не показывать "Press Enter" при возврате из подменю (3=snapshot, 12=check_sync)
      if [[ "$choice" != "3" && "$choice" != "11" ]]; then
        echo ""
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
      fi
    fi
  done
}

# === Parse command-line arguments ===
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -v|--version)
        print_version
        ;;
      -U|--update-installer)
        update_installer
        ;;
      -h|--help)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -v, --version              Print installer version"
        echo "  -U, --update-installer     Update installer script to latest version"
        echo "  -h, --help                 Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0                        # Run interactive menu"
        echo "  $0 -v                     # Print installer version"
        echo "  $0 -U                     # Update installer script"
        exit 0
        ;;
      *)
        warn "Unknown option: $1. Use --help for usage information."
        ;;
    esac
    shift
  done
}

# === Run ===
parse_args "$@"
# Check for installer updates on startup (non-blocking)
check_installer_up_to_date || true
init_languages "${1:-}"
check_dependencies
main_menu
