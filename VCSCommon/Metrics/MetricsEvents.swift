import Foundation
import FirebaseAnalytics

public class MetricsEvent: NSObject {
    //MARK: - EVENTS_LIST_ACTION
    public static let LIST_ACTION__SELECT_ITEMS                           = "list_action__select_items"
    public static let LIST_ACTION__REALOD_ITEMS                           = "list_action__reload_items"
    public static let LIST_ACTION__DOWNLOAD                               = "list_action__download"
    public static let LIST_ACTION__SHARE_WITH_USER                        = "list_action__share_with_user"
    public static let LIST_ACTION__SHARE_WITH_OS                          = "list_action__share_with_OS"
    public static let LIST_ACTION__SHARE_LINK                             = "list_action__share_link"
    public static let LIST_ACTION__DELETE                                 = "list_action__delete"
    public static let LIST_ACTION__STOP_SHARING                           = "list_action__stop_sharing"
    public static let LIST_ACTION__DELETE_LOCALLY                         = "list_action__delete_locally"
    public static let LIST_ACTION__ADD_TO_HOME                            = "list_action__add_to_home"
    public static let LIST_ACTION__REMOVE_FROM_HOME                       = "list_action__remove_from_Home"
    
    public static let LIST_ACTION__ITEM_OPEN__PDF_VIEWER                  = "list_action__item_open__pdf_viewer"
    public static let LIST_ACTION__ITEM_OPEN__OLD_PDF_VIEWER              = "list_action__item_open__old_pdf_viewer"
    public static let LIST_ACTION__ITEM_OPEN_QUICK_LOOK_PDF_VIEWER        = "quick_look_pdf_viewer__opened"
    public static let LIST_ACTION__ITEM_OPEN__SYSTEM_PREVIEWER            = "list_action__item_open__system_previewer"
    public static let LIST_ACTION__ITEM_OPEN__VGM                         = "list_action__item_open__vgm"
    public static let LIST_ACTION__ITEM_OPEN__AR_Viewer                   = "list_action__item_open__ar_viewer"
    public static let LIST_ACTION__ITEM_OPEN__PANORAMA_UNITY              = "list_action__item_open__panorama_unity"
    public static let LIST_ACTION__ITEM_OPEN__VIDEO_UNITY                 = "list_action__item_open__video_unity"
    public static let LIST_ACTION__ITEM_OPEN__PTS_VIEWER                  = "list_action__item_open__pts_viewer"
    public static let LIST_ACTION__ITEM_OPEN__VCDOC_VIEWER                = "list_action__item_open__vcdoc_viewer"
    
    public static let LIST_ACTION__ADD__SINGLE_PHOTO_UPLOAD               = "list_action__add__single_photo_upload"
    public static let LIST_ACTION__ADD__CREATE_FOLDER                     = "list_action__add__create_folder"
    public static let LIST_ACTION__ADD__PHOTOS_TO_3D                      = "list_action__add__photos_to_3d"
    public static let LIST_ACTION__ADD__QR_CODE_SCANNER                   = "list_action__add__qr_code_scanner"
    public static let LIST_ACTION__ADD__POINT_CLOUD                       = "list_action__add__point_cloud"
    public static let LIST_ACTION__ADD_ROOM_SCAN                          = "list_action__add__room_scan"
    
    public static let LIST_ACTION__JOB__GENERATE_PDF                      = "list_action__job__generate_pdf"
    public static let LIST_ACTION__JOB__GENERATE_3D                       = "list_action__job__generate_3d"
    public static let LIST_ACTION__JOB__PHOTOS_TO_3D                      = "list_action__job__photos_to_3d"
    
    
    
    //MARK: - EVENTS_PDF_VIEWER_ACTIONS
    public static let PDF_VIEWER_ACTIONS__PEN_TOOL_SELECTED               = "pdf_viewer_actions__pen_selected"
    public static let PDF_VIEWER_ACTIONS__REDLINE_TOOL_SELECTED           = "pdf_viewer_actions__redline_selected"
    
    public static let PDF_VIEWER_ACTIONS__LINE_TOOL_SELECTED              = "pdf_viewer_actions__line_selected"
    public static let PDF_VIEWER_ACTIONS__RECTANGLE_TOOL_SELECTED         = "pdf_viewer_actions__rectangle_selected"
    public static let PDF_VIEWER_ACTIONS__ELLIPSE_TOOL_SELECTED           = "pdf_viewer_actions__ellipse_selected"
    public static let PDF_VIEWER_ACTIONS__MEASURE_TOOL_SELECTED           = "pdf_viewer_actions__measure_selected"
    public static let PDF_VIEWER_ACTIONS__ANGLE_TOOL_SELECTED             = "pdf_viewer_actions__angle_selected"
    public static let PDF_VIEWER_ACTIONS__PATH_TOOL_SELECTED              = "pdf_viewer_actions__path_selected"
    public static let PDF_VIEWER_ACTIONS__TEXT_TOOL_SELECTED              = "pdf_viewer_actions__text_selected"
    public static let PDF_VIEWER_ACTIONS__SELECTION_TOOL_SELECTED         = "pdf_viewer_actions__selection_selected"
    
    public static let PDF_VIEWER_ACTIONS__PEN_ANNOTATION_CREATED          = "pdf_viewer_actions__pen_annotation_created"
    public static let PDF_VIEWER_ACTIONS__REDLINE_ANNOTATION_CREATED      = "pdf_viewer_actions__redline_annotation_created"
    public static let PDF_VIEWER_ACTIONS__LINE_ANNOTATION_CREATED         = "pdf_viewer_actions__line_annotation_created"
    public static let PDF_VIEWER_ACTIONS__RECTANGLE_ANNOTATION_CREATED    = "pdf_viewer_actions__rectangle_annotation_created"
    public static let PDF_VIEWER_ACTIONS__ELLIPSE_ANNOTATION_CREATED      = "pdf_viewer_actions__ellipse_annotation_created"
    public static let PDF_VIEWER_ACTIONS__TEXT_ANNOTATION_CREATED         = "pdf_viewer_actions__text_annotation_created"
    
    public static let PDF_VIEWER_ACTIONS__ANNOTATION_SELECTED             = "pdf_viewer_actions__annotation_selected"
    public static let PDF_VIEWER_ACTIONS__TEXT_ANNOTATION_SELECTED        = "pdf_viewer_actions__text_annotation_selected"
    
    public static let PDF_VIEWER_ACTIONS__ANNOTATION_RESIZED              = "pdf_viewer_actions__annotation_resized"
    public static let PDF_VIEWER_ACTIONS__TEXT_ANNOTATION_RESIZED         = "pdf_viewer_actions__text_annotation_resized"
    public static let PDF_VIEWER_ACTIONS__ANNOTATION_MOVED                = "pdf_viewer_actions__annotation_moved"
    public static let PDF_VIEWER_ACTIONS__TEXT_ANNOTATION_MOVED           = "pdf_viewer_actions__text_annotation_moved"
    
    public static let PDF_VIEWER_ACTIONS__UNDO_USED                       = "pdf_viewer_actions__annotation_undone"
    public static let PDF_VIEWER_ACTIONS__DELETE_USED                     = "pdf_viewer_actions__annotation_deleted"
    public static let PDF_VIEWER_ACTIONS__EDIT_USED                       = "pdf_viewer_actions__annotation_edited"
    
    public static let PDF_VIEWER_ACTIONS__SINGLE_PATH_MEASURED            = "pdf_viewer_actions__single_path_measured"
    public static let PDF_VIEWER_ACTIONS__MULTI_PATH_MEASURED             = "pdf_viewer_actions__multi_path_measured"
    public static let PDF_VIEWER_ACTIONS__ANGLE_MEASURED                  = "pdf_viewer_actions__angle_measured"
    public static let PDF_VIEWER_ACTIONS__MEASUREMENT_HANDLER_MOVED       = "pdf_viewer_actions__measurement_handler_moved"
    public static let PDF_VIEWER_ACTIONS__MULTI_FINGER_PAN_OR_ZOOM        = "pdf_viewer_actions__multi_finger_pan_or_zoom"
    
    public static let PDF_VIEWER_ACTIONS__SAVE_MARKUP                     = "pdf_viewer_actions__save_markup"
    public static let PDF_VIEWER_ACTIONS__PAGE_CHANGED_FROM_THUMBNAIL     = "pdf_viewer_actions__page_changed_from_thumbnail"
    public static let PDF_VIEWER_ACTIONS__PAGE_CHANGED_FROM_SWIPE         = "pdf_viewer_actions__page_changed_from_swipe"
    public static let PDF_VIEWER_ACTIONS__DOUBLE_TAP_ZOOM_IN              = "pdf_viewer_actions__double_tap_zoom_in"
    public static let PDF_VIEWER_ACTIONS__DOUBLE_TAP_ZOOM_OUT             = "pdf_viewer_actions__double_tap_zoom_out"
    public static let PDF_VIEWER_ACTIONS__SNAP_POINTS_SETTINGS_POP_UP_OPENED =
    "pdf_viewer_actions__snap_points_settings_pop_up_opened"
    public static let PDF_VIEWER_ACTIONS__SNAP_POINTS_SETTING_TURNED_ON   = "pdf_viewer_actions__snap_points_setting_turned_on"
    public static let PDF_VIEWER_ACTIONS__SNAP_POINTS_SETTING_TURNED_OFF  = "pdf_viewer_actions__snap_points_setting_turned_off"
    
    
    
    //MARK: - EVENTS_ACCOUNT
    public static let ACCOUNT_ACTIONS__HELP_OPENED                        = "account_actions__help_opened"
    public static let ACCOUNT_ACTIONS__ABOUT_OPENED                       = "account_actions__about_opened"
    public static let ACCOUNT_ACTIONS__FEEDBACK_OPENED                    = "account_actions__feedback_opened"
    public static let ACCOUNT_ACTIONS__FEEDBACK_SENT                      = "account_actions__feedback_sent"
    public static let ACCOUNT_ACTIONS__CLEAR_CACHE_BUTTON_CLICKED         = "account_actions__clear_cache_button_clicked"
    public static let ACCOUNT_ACTIONS__TOUR_OPENED                        = "account_actions__tour_opened"
    public static let ACCOUNT_ACTIONS__DELETE_ACCOUT                      = "account_actions__delete_account"
    
    
    
    //MARK: - EVENTS_AR_VIEWER_ACTIONS
    public static let AR_VIEWER_ACTIONS__AR_VIEWER_SCREENSHOT_TAKEN       = "ar_viewer_actions__screenshot_taken"
    public static let AR_VIEWER_ACTIONS__AR_VIEWER_MODEL_PLACED           = "ar_viewer_actions__model_placed"
    public static let AR_VIEWER_ACTIONS__AR_VIEWER_RESET_SESSION          = "ar_viewer_actions__reset_session"
    public static let AR_VIEWER_ACTIONS__AR_VIEWER_ENTER_FULLSCREEN       = "ar_viewer_actions__enter_fullscreen"
    
    public static let AR_VIEWER_ACTIONS__AR_ERROR_UNSUPPORTED_DEVICE      = "ar_viewer_actions__error_unsupported_device"
    public static let AR_VIEWER_ACTIONS__AR_FILE_OPEN_VGX                 = "ar_viewer_actions__open_vgx"
    public static let AR_VIEWER_ACTIONS__AR_FILE_OPEN_OTHER               = "ar_viewer_actions__open_other"
    
    
    
    //MARK: - EVENTS_VGM_VIEWER_ACTIONS
    public static let VGM_VIEWER_ACTIONS__FLYOVER_VIEW_MODE               = "vgm_viewer_actions__flyover_view_mode"
    public static let VGM_VIEWER_ACTIONS__WALKTHROUGH_VIEW_MODE           = "vgm_viewer_actions__walkthrough_view_mode"
    public static let VGM_VIEWER_ACTIONS__HELP_OPENED                     = "vgm_viewer_actions__help_opened"
    public static let VGM_VIEWER_ACTIONS__SETTINGS_OPENED                 = "vgm_viewer_actions__settings_opened"
    public static let VGM_VIEWER_ACTIONS__SKYBOX_SETTINGS_OPENED          = "vgm_viewer_actions__skybox_settings_opened"
    public static let VGM_VIEWER_ACTIONS__WALKTHROUGH_SETTINGS_OPENED     = "vgm_viewer_actions__walkthrough_settings_opened"
    public static let VGM_VIEWER_ACTIONS__FLYOVER_SETTINGS_OPENED         = "vgm_viewer_actions__flyover_settings_opened"
    public static let VGM_VIEWER_ACTIONS__DRAWER_TAPPED_OPENED            = "vgm_viewer_actions__drawer_tapped_opened"
    public static let VGM_VIEWER_ACTIONS__DRAWER_SAVED_VIEW_ACTIVATED     = "vgm_viewer_actions__drawer_saved_view_activated"
    public static let VGM_VIEWER_ACTIONS__DRAWER_RENDERWORKS_ACTIVATED    = "vgm_viewer_actions__renderworks_camera_activated"
    public static let VGM_VIEWER_ACTIONS__DRAWER_LAYERS_ACTIVATED         = "vgm_viewer_actions__drawer_layers_activated"
    public static let VGM_VIEWER_ACTIONS__RECEIVED_MEMORY_WARNING         = "vgm_viewer_actions__received_memory_warning"
    
    
    
    //MARK: - EVENTS_AR_MEASURE_ACTIONS
    public static let AR_MEASURE_ACTIONS__3D_POLYGON_WORKFLOW_CHOSEN      = "ar_measure_actions_3d_polygon_workflow_chosen"
    public static let AR_MEASURE_ACTIONS__ROOM_WORKFLOW_CHOSEN            = "ar_measure_actions_room_workflow_chosen"
    public static let AR_MEASURE_ACTIONS__PROJECT_CREATED                 = "ar_measure_actions_project_created"
    public static let AR_MEASURE_ACTIONS__MEASUREMENT_SAVED               = "ar_measure_actions_measurement_saved"
    public static let AR_MEASURE_ACTIONS__CLOUD_JOB_STARTED               = "ar_measure_actions_cloud_job_started"
    public static let AR_MEASURE_ACTIONS__MEASUREMENT_VIEWED              = "ar_measure_actions_measurement_viewed"
    public static let AR_MEASURE_ACTIONS__PDF_GENERATED                   = "ar_measure_actions_pdf_generated"
    public static let AR_MEASURE_ACTIONS__IMAGE_GENERATED                 = "ar_measure_actions_image_generated"
    
    
    
    //MARK: - EVENTS_USER_STATE
    public static let USER__LOGIN                                         = AnalyticsEventLogin
    public static let USER__LOGOUT                                        = "logout"
    
    
    
    //MARK: - EVENTS_USER_STATE
    public static let APP_EVENTS_DEEPLINK                                 = "app_events__deeplink"
    
    
    
}
