""

def _list_to_set(_list):
    return struct(_values = {e: None for e in _list})
def _set_to_list(_set):
    return _set._values.keys()
def _set_equal(rhs, lhs):
    return rhs._values == lhs._values

def list_remove_duplicates(_list):
    _set = _list_to_set(_list)
    return _set_to_list(_set)

def list_same_elements(list_a, list_b):
    _set_a = _list_to_set(list_a)
    _set_b = _list_to_set(list_b)
    return _set_equal(_set_a, _set_b)

# TODO:
# buildifier: disable=function-docstring
def flag_change_external_path(flag, path_to_external):
    if flag.startswith('-Iexternal/'):
        return flag.replace('-Iexternal/', '-I{}external/'.format(path_to_external))
    if flag.startswith('-Lexternal/'):
        return flag.replace('-Lexternal/', '-L{}external/'.format(path_to_external))
    if flag.startswith('external/'):
        return flag.replace('external/', '{}external/'.format(path_to_external))
    else:
        return flag
