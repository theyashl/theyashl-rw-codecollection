class S3Objects:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def get_report_msg(self, count):
        return f"There are {count} objects present in bucket."