package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.workbench.domain.TranRemark;
import com.bjpowernode.crm.workbench.mapper.TranRemarkMapper;
import com.bjpowernode.crm.workbench.service.TranRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service("tranRemarkService")
public class TranRemarkServiceImpl implements TranRemarkService {

    @Autowired
    private TranRemarkMapper tranRemarkMapperl;

    @Override
    public List<TranRemark> queryTranRemarkForDetailByTranId(String tranId) {
        return tranRemarkMapperl.selectTranRemarkForDeatilByTranId(tranId);
    }
}
