import os

def create_folder_structure():
    # Define the folder structure with files
    structure = {
        'lib': {
            'core': {
                'constants': ['app_constants.dart', 'api_constants.dart', 'language_constants.dart'],
                'error': ['exceptions.dart', 'failures.dart'],
                'network': ['network_info.dart', 'dio_client.dart'],
                'utils': ['app_utils.dart', 'validators.dart', 'extensions.dart'],
                'themes': ['app_theme.dart', 'app_colors.dart', 'app_text_styles.dart'],
                'services': ['injection_container.dart', 'service_locator.dart'],
                'usecases': ['usecase.dart']
            },
            'features': {
                'translation': {
                    'data': {
                        'datasources': ['translation_local_datasource.dart', 'translation_remote_datasource.dart'],
                        'models': ['translation_model.dart', 'language_model.dart'],
                        'repositories': ['translation_repository_impl.dart']
                    },
                    'domain': {
                        'entities': ['translation.dart', 'language.dart'],
                        'repositories': ['translation_repository.dart'],
                        'usecases': ['translate_text.dart', 'detect_language.dart', 'get_supported_languages.dart']
                    },
                    'presentation': {
                        'bloc': ['translation_bloc.dart', 'translation_event.dart', 'translation_state.dart'],
                        'pages': ['translation_page.dart'],
                        'widgets': ['language_selector.dart', 'translation_input.dart', 'translation_output.dart', 'voice_input_button.dart']
                    }
                },
                'speech': {
                    'data': {
                        'datasources': ['speech_datasource.dart'],
                        'repositories': ['speech_repository_impl.dart']
                    },
                    'domain': {
                        'entities': ['speech_result.dart'],
                        'repositories': ['speech_repository.dart'],
                        'usecases': ['start_listening.dart', 'stop_listening.dart', 'text_to_speech.dart']
                    },
                    'presentation': {
                        'bloc': ['speech_bloc.dart', 'speech_event.dart', 'speech_state.dart'],
                        'widgets': ['speech_button.dart', 'speech_animation.dart']
                    }
                },
                'camera': {
                    'data': {
                        'datasources': ['ocr_datasource.dart'],
                        'repositories': ['camera_repository_impl.dart']
                    },
                    'domain': {
                        'entities': ['ocr_result.dart'],
                        'repositories': ['camera_repository.dart'],
                        'usecases': ['capture_image.dart', 'extract_text.dart']
                    },
                    'presentation': {
                        'bloc': ['camera_bloc.dart', 'camera_event.dart', 'camera_state.dart'],
                        'pages': ['camera_page.dart'],
                        'widgets': ['camera_preview.dart', 'ocr_overlay.dart']
                    }
                },
                'history': {
                    'data': {
                        'datasources': ['history_local_datasource.dart'],
                        'models': ['history_item_model.dart'],
                        'repositories': ['history_repository_impl.dart']
                    },
                    'domain': {
                        'entities': ['history_item.dart'],
                        'repositories': ['history_repository.dart'],
                        'usecases': ['get_history.dart', 'save_to_history.dart', 'delete_history_item.dart', 'clear_history.dart']
                    },
                    'presentation': {
                        'bloc': ['history_bloc.dart', 'history_event.dart', 'history_state.dart'],
                        'pages': ['history_page.dart'],
                        'widgets': ['history_item_widget.dart', 'history_search.dart']
                    }
                },
                'favorites': {
                    'data': {
                        'datasources': ['favorites_local_datasource.dart'],
                        'models': ['favorite_model.dart'],
                        'repositories': ['favorites_repository_impl.dart']
                    },
                    'domain': {
                        'entities': ['favorite.dart'],
                        'repositories': ['favorites_repository.dart'],
                        'usecases': ['get_favorites.dart', 'add_to_favorites.dart', 'remove_from_favorites.dart']
                    },
                    'presentation': {
                        'bloc': ['favorites_bloc.dart', 'favorites_event.dart', 'favorites_state.dart'],
                        'pages': ['favorites_page.dart'],
                        'widgets': ['favorite_item_widget.dart']
                    }
                },
                'conversation': {
                    'data': {
                        'models': ['conversation_model.dart'],
                        'repositories': ['conversation_repository_impl.dart']
                    },
                    'domain': {
                        'entities': ['conversation.dart', 'message.dart'],
                        'repositories': ['conversation_repository.dart'],
                        'usecases': ['start_conversation.dart', 'add_message.dart', 'translate_message.dart']
                    },
                    'presentation': {
                        'bloc': ['conversation_bloc.dart', 'conversation_event.dart', 'conversation_state.dart'],
                        'pages': ['conversation_page.dart'],
                        'widgets': ['conversation_bubble.dart', 'language_switch_button.dart']
                    }
                },
                'settings': {
                    'data': {
                        'datasources': ['settings_local_datasource.dart'],
                        'models': ['settings_model.dart'],
                        'repositories': ['settings_repository_impl.dart']
                    },
                    'domain': {
                        'entities': ['app_settings.dart'],
                        'repositories': ['settings_repository.dart'],
                        'usecases': ['get_settings.dart', 'update_settings.dart']
                    },
                    'presentation': {
                        'bloc': ['settings_bloc.dart', 'settings_event.dart', 'settings_state.dart'],
                        'pages': ['settings_page.dart'],
                        'widgets': ['settings_tile.dart', 'theme_selector.dart']
                    }
                }
            },
            'shared': {
                'widgets': ['custom_app_bar.dart', 'custom_button.dart', 'custom_text_field.dart', 'loading_widget.dart', 'error_widget.dart', 'bottom_nav_bar.dart'],
                'utils': ['constants.dart', 'helpers.dart', 'enums.dart'],
                'extensions': ['context_extensions.dart', 'string_extensions.dart', 'widget_extensions.dart']
            },
            'config': {
                'routes': ['app_router.dart', 'route_names.dart'],
                'themes': ['light_theme.dart', 'dark_theme.dart']
            },
            '': ['main.dart']
        },
        'assets': {
            'images': {
                'logo': [],
                'icons': [],
                'flags': []
            },
            'translations': ['en.json', 'es.json', 'fr.json', 'de.json', 'ar.json', 'zh.json', 'ja.json'],
            'animations': ['loading.json', 'voice_animation.json']
        }
    }

    def create_files(base_path, folder_dict):
        for folder_name, content in folder_dict.items():
            # Create folder path
            folder_path = os.path.join(base_path, folder_name) if folder_name else base_path
            
            # Create folder if it doesn't exist
            if folder_name:
                os.makedirs(folder_path, exist_ok=True)
            
            # If content is a list, create files
            if isinstance(content, list):
                for file_name in content:
                    file_path = os.path.join(folder_path, file_name)  # Use file_name instead of file_path
                    # Create empty file
                    open(file_path, 'a').close()
            # If content is a dict, recurse into subfolders
            elif isinstance(content, dict):
                create_files(folder_path, content)

    # Create the structure directly in the current directory
    create_files('.', folder_dict=structure)
    print("Folder structure created successfully!")

if __name__ == "__main__":
    create_folder_structure()